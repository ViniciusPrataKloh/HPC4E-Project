#!/bin/bash

file=[OUTPUT_DIRECTORY]/power.dat

date +%H:%M:%S.%N >> $file
echo -n "Total:" >> $file
cat /sys/bus/i2c/drivers/ina3221x/0-0041/iio_device/in_power0_input >> $file
echo -n "GPU:" >> $file
cat /sys/bus/i2c/drivers/ina3221x/0-0040/iio_device/in_power0_input >> $file
echo -n "CPU:" >> $file
cat /sys/bus/i2c/drivers/ina3221x/0-0041/iio_device/in_power1_input >> $file
echo -n "Memory:" >> $file
cat /sys/bus/i2c/drivers/ina3221x/0-0041/iio_device/in_power2_input >> $file

