package naRobot

import (
	"bytes"
	"encoding/binary"
	"log"
	"net"
)

type NAServer struct {
	conn *net.UDPConn
}

type NANetEvent struct {
	x, y int8
	servoX, servoY uint8
}

func InitNAServer() NAServer {
	RemoteIP := "192.168.0.100:8080"
	ListenIP := ":8080" // Listen IP not needed. Only port.
	
	log.Printf("Opening UDP connection...")

	RemoteAddr, err := net.ResolveUDPAddr("udp", RemoteIP)
	if err != nil {
		log.Println("RemoteAddr Error: ", err)
	}
	log.Printf("Sending to remote:" + RemoteIP)
	
	ListenAddr, err := net.ResolveUDPAddr("udp", ListenIP)
	if err != nil {
		log.Println("ListenAddr Error: ", err)
	}

	conn, err := net.DialUDP("udp", ListenAddr, RemoteAddr)
	if err != nil {
		log.Println("DialUDP Error: ", err)
	}

	server := NAServer{conn: conn}

	return server
}

func (nas *NAServer) readLoop(c chan NANetEvent) {

	input := make([]byte, 4, 4)

	for {

		nBytes, err := nas.conn.Read(input)

		if nBytes != 4 {
			continue
		}

		byteReader := bytes.NewReader(input)

		event := new(NANetEvent)
		
		binary.Read(byteReader, binary.LittleEndian, &event.x)

		binary.Read(byteReader, binary.LittleEndian, &event.y)

		binary.Read(byteReader, binary.LittleEndian, &event.servoX)

		err = binary.Read(byteReader, binary.LittleEndian, &event.servoY)

		if err != nil {
			log.Fatal("binary.Read failed:", err)
		}

		//log.Print("I has a net event: %+v", event)

		c <- *event
	}
}

func (nas *NAServer) send(data *ChairResponse) {
	//lets send some chair data!
	go func(b []byte) {
		nas.conn.Write(b)
	}(data.bytes())
}
