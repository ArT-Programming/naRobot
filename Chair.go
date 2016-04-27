package naRobot

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"github.com/tarm/serial"
	"io"
	"log"
	"time"
)

type Chair struct {
	devicePath                            string
	device                                *serial.Port
	sensor                                *serial.Port
	x, y                                  int8
	pendingCommand, battery, speed, error uint8
	chairMsgs                             chan ChairResponse
	sensorData                            SensorData
	cntr                                  uint64
	naServer                             *NAServer
}

type ChairResponse struct {
	typ      uint8
	error    uint8
	unknown2 uint8
	battery  uint8
	speed    uint8
	crc      uint8
}

type chairData struct {
	typ     uint8
	command uint8
	unknown uint8
	y       int8
	x       int8
	crc     uint8
}

type SensorData struct {
	dist	[]uint8
}

func (d *ChairResponse) bytes() []byte {
	bytes := []byte{d.typ, d.error, d.unknown2, d.battery, d.speed, d.crc}
	return bytes
}

func InitChair(c *serial.Config , s *serial.Config) Chair {
	log.Printf("Chair with path: %s", c.Name)
	log.Printf("Sensor with path: %s", s.Name)

	chairSerial, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal(err)
	}

	
	sensorSerial, err := serial.OpenPort(s)
	if err != nil {
		log.Fatal(err)
	}

	naServer := InitNAServer()
	chair := Chair{devicePath: c.Name, device: chairSerial, sensor: sensorSerial, chairMsgs: make(chan ChairResponse), naServer: &naServer}
	chair.sensorData.dist = make([]uint8,3,3)
	return chair
}

func (c *Chair) Loop() {

	go c.readLoop()
	
	senData := make(chan SensorData)
	
	go c.sensorRead(senData)

	netEventChan := make(chan NANetEvent)

	go c.naServer.readLoop(netEventChan)



	ticker := time.Tick(10 * time.Millisecond)

	for {
		select {

		case cRes := <-c.chairMsgs:
			c.battery = cRes.battery
			c.speed = cRes.speed
			c.error = cRes.error
			if c.cntr%5 == 1 {
				c.naServer.send(&cRes)
			}
		case readSenData := <- senData:
			//fmt.Print("Now i'm done with channeling, func go!")
			c.handleSensorData(&readSenData)
		case nEvent := <-netEventChan:
			c.handleNetEvent(&nEvent)
		case <-ticker:
			start := time.Now()
			c.sendData()
			c.formatCliLine(start)
		}
	}
}

func (c *Chair) handleSensorData(data *SensorData) {
	c.sensorData.dist = data.dist
	
	b := make([]byte, 3, 3)
	b[0] = c.sensorData.dist[0]
	b[1] = c.sensorData.dist[1]
	b[2] = c.sensorData.dist[2]
	c.naServer.conn.Write(b)
}

func (c *Chair) sensorRead(d chan SensorData) {

	input := make([]byte, 4, 4)
	startByte := make([]byte, 1, 1)
	for {

		//Wait for the start byte, its 255 (0xff)
		for {
			c.sensor.Read(startByte)
			//fmt.Println(startByte[0])
			if startByte[0] == 255 {
				break
			}
		}

		_, err := io.ReadAtLeast(c.sensor, input, 4)

		if err != nil {
			log.Fatal("Problem reading sensor:", err)
		}

		calcSum := byte(0)

		for i := 0; i < 3; i++ {
			calcSum = calcSum + input[i]
		}
		//fmt.Println(input)

		if calcSum == input[3] {
			values := input[:3]
			senData := SensorData{dist: values}//, dist[1]: input[1], dist[2]: input[2]}
			//log.Printf("Sensor said: %v", senData)

			d <- senData
		}
	}
}

func (c *Chair) handleNetEvent(e *NANetEvent) {
	c.y = e.y
	c.x = e.x
}

func (c *Chair) sendData() {
	c.cntr++
	payLoad := chairData{typ: 74, command: c.pendingCommand, y: c.y, x: c.x}

	//reset the command
	c.pendingCommand = 0

	c.device.Write(payLoad.bytes())
}

func (d *chairData) bytes() []byte {
	bytes := []byte{d.typ, d.command, d.unknown, byte(d.x), byte(d.y), 0}
	bytes[5] = calculateCheckSum(bytes)
	return bytes
}

func calculateCheckSum(b []byte) byte {
	sum := byte(255)

	for i := 0; i < 5; i++ {
		sum = sum - b[i]
	}

	return sum
}

func (c *Chair) formatCliLine(start time.Time) {
	elapsed := time.Since(start)
	fmt.Printf("\rS1:%d S2:%d S3:%d E:%d B:%d S:%d Y:%d X:%d C:%d elpsd: %v      ", c.sensorData.dist[0], c.sensorData.dist[1], c.sensorData.dist[2], c.error, c.battery, c.speed, c.y, c.x, c.cntr, elapsed)
}

func (c *Chair) readLoop() {

	input := make([]byte, 5, 5)
	startByte := make([]byte, 1, 1)
	for {

		//Wait for the start byte, its 84
		for {
			c.device.Read(startByte)
			if startByte[0] == 84 {
				break
			}
		}

		_, err := io.ReadAtLeast(c.device, input, 5)

		if err != nil {
			log.Fatal("Problem reading chair:", err)
		}

		byteReader := bytes.NewReader(input)

		cRes := ChairResponse{typ: 84}

		binary.Read(byteReader, binary.LittleEndian, &cRes.error)
		binary.Read(byteReader, binary.LittleEndian, &cRes.unknown2)
		binary.Read(byteReader, binary.LittleEndian, &cRes.battery)
		binary.Read(byteReader, binary.LittleEndian, &cRes.speed)

		err = binary.Read(byteReader, binary.LittleEndian, &cRes.crc)

		if err != nil {
			log.Fatal("binary.Read failed:", err)
		}

		//log.Printf("Chair said: %v", cRes)

		c.chairMsgs <- cRes
	}
}