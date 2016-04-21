package main

import (
	"github.com/BurntSushi/toml"
	"github.com/ArT-Programming/naRobot"
	"github.com/tarm/serial"
	"log"
	"os"
    "fmt"
)

type Config struct {
	Chair    serial.Config
}

func main() {
	if len(os.Args) <= 1 {
        fmt.Print("os.Args = ")
        fmt.Println(os.Args)
        fmt.Println()
		log.Fatal("Provide configuration path as first argument")
	}

	configPath := os.Args[1]

	config := Config{}

	log.Printf("Reading configuration from %s", configPath)

	if _, err := toml.DecodeFile(configPath, &config); err != nil {
		log.Fatal(err)
	}

	chair := naRobot.InitChair(&config.Chair)

	chair.Loop()

	log.Printf("Bye")

}
