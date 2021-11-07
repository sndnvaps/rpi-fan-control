#!/bin/bash
### BEGIN INIT INFO

# Provides:            rpi_fan_control


# Default-Start:        2 3 4 5

# Default-Stop:        0 1 6

# Short-Description:    Raspberry Pi 5v fan_control initscript
# origin post by https://www.jianshu.com/p/425edae3fc63
# /etc/init.d/rpi_fan_control start|status|stop|reload|restart|force-reload

PROG="rpi_fan_control"

PROG_PATH="/usr/local/rpi_fan_control"
PROG_ARGS="-start=50 -stop=38"

DELAY=5

start() {
	fan_control_pid=$(ps -e|grep $PROG|awk '{print $1}')
	if [ ! -n "$fan_control_pid" ]; then
		echo "Error! $PROG is currently running!" 1>&2
		exit 1
	else
		cd $PROG_PATH
		./$PROG $PROG_ARGS &
		echo "$PROG started, waiting $DELAY seconds..."
	fi
}

stop() {
	fan_control_pid=$(ps -e|grep $PROG|awk '{print $1}')
	if [ ! -n "$fan_control_pid" ]; then
		echo "Cant't Find $PROG Process"
	else
		echo "Stop $PROG... pid: $fan_control_pid" 1>&2
		kill -9 $fan_control_pid
	fi
}

status() {
	if [ -e $PROG ]; then
		echo "$0 service start"
	else
		echo "$0 service stop"
	fi
}

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

case "$1" in
	start)
		start
	;;
	stop)
		stop
	;;
	status)
		status
	;;
	reload|restart|force-reload)
		stop
		start
	;;
	*)
		echo "Usage: $0 {start|stop|status|reload|restart|force-reload}" 1>&2
		exit 1
esac
