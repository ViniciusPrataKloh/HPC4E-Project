#!/bin/bash

#IPMI_TEMP_OUTPUT=`/usr/sbin/ipmi-sensors`
### Power and Temperature ###
#CURRENT_TEMP1=$(echo $IPMI_TEMP_OUTPUT | /usr/sbin/ipmi-sensors | grep CPU1 | grep Temp | awk '{print $8}')
#CURRENT_TEMP2=$(echo $IPMI_TEMP_OUTPUT | /usr/sbin/ipmi-sensors | grep CPU2 | grep Temp | awk '{print $8}')

#echo "$CURRENT_TEMP1  $CURRENT_TEMP2" >> tempetature.dat
saida_file=/home/nvidia/Testes_ARM/Monitor/power.dat

date +%H:%M:%S.%N >> $saida_file
echo -n "Total:" >> $saida_file
cat /sys/bus/i2c/drivers/ina3221x/0-0041/iio_device/in_power0_input >> $saida_file
echo -n "GPU:" >> $saida_file
cat /sys/bus/i2c/drivers/ina3221x/0-0040/iio_device/in_power0_input >> $saida_file
echo -n "CPU:" >> $saida_file
cat /sys/bus/i2c/drivers/ina3221x/0-0041/iio_device/in_power1_input >> $saida_file
echo -n "Memory:" >> $saida_file
cat /sys/bus/i2c/drivers/ina3221x/0-0041/iio_device/in_power2_input >> $saida_file

