#!/bin/sh
echo 1-7 > /sys/bus/usb/drivers/usb/unbind
echo on > /sys/devices/pci0000:00/0000:00:15.1/i2c_designware.1/power/control
