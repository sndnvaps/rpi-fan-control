package main

import (
	"bufio"
	"flag"
	"io"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
	"time"

	"github.com/stianeikeland/go-rpio"
)

func main() {
	minTemp := flag.Float64("stop", 60, "Temperature to stop fan at Celsius temp")
	maxTemp := flag.Float64("start", 70, "Temperature to start fan at Celsius temp")
	tempSource := flag.String("source", "/sys/class/thermal/thermal_zone0/temp", "Path to file of temperature source")
	gpioPin := flag.Int("pin", 16, "GPIO pin for fan control")
	flag.Parse()

	err := rpio.Open()

	if err != nil {
		log.Fatal(err)
	}

	pin := rpio.Pin(*gpioPin)
	pin.Output()

	fanOn := false
	pin.Low()

	for {
		data, err := ioutil.ReadFile(*tempSource)

		intData, err := ReadInts(strings.NewReader(string(data)))

		if err != nil {
			log.Fatal(err)
		}

		temp := float64(intData[0]) / 1000

		if err != nil {
			log.Fatal(err)
		}

		if fanOn {
			if int(temp) <= int(*minTemp) {
				log.Printf("Temperature is %v Celsius, Stopping fan!", int(temp))
				pin.Low()
				fanOn = false
			}
		} else {
			if int(temp) >= int(*maxTemp) {
				log.Printf("Temperature is %v Celsius, Starting fan!", int(temp))
				pin.High()
				fanOn = true
			}
		}
		time.Sleep(5 * time.Second)
	}
}

func ReadInts(r io.Reader) ([]int, error) {
	scanner := bufio.NewScanner(r)
	scanner.Split(bufio.ScanWords)
	var result []int
	for scanner.Scan() {
		x, err := strconv.Atoi(scanner.Text())
		if err != nil {
			return result, err
		}
		result = append(result, x)
	}
	return result, scanner.Err()
}
