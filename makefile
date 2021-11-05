target:=rpi_fan_control
source:=*.go

all: deps build install

build: deps
	go build -o ${target} ${source}

deps:
	@echo download package
	@go mod download

install: deps build
	install -D ${target} /usr/local/rpi_fan_control/rpi_fan_control
	chmod 0755 /usr/local/rpi_fan_control/rpi_fan_control
	install rpi_fan_control_service.sh /etc/init.d/rpi_fan_control
	chmod 0755 /etc/init.d/rpi_fan_control
	update-rc.d  rpi_fan_control defaults

uninstall:
	rm -rf /usr/local/rpi_fan_control
	update-rc.d -f rpi_fan_control remove
	rm -rf /etc/init.d/rpi_fan_control

clean:
	rm -rf  $(target)

.PHONY: all deps build install uninstall clean
