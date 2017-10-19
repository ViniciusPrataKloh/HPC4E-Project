#!/bin/bash

#IPMI_TEMP_OUTPUT=`/usr/sbin/ipmi-sensors`
### Power and Temperature ###
#CURRENT_TEMP1=$(echo $IPMI_TEMP_OUTPUT | /usr/sbin/ipmi-sensors | grep CPU1 | grep Temp | awk '{print $8}')
#CURRENT_TEMP2=$(echo $IPMI_TEMP_OUTPUT | /usr/sbin/ipmi-sensors | grep CPU2 | grep Temp | awk '{print $8}')

#echo "$CURRENT_TEMP1  $CURRENT_TEMP2" >> tempetature.dat
saida_file=/home/nvidia/Testes_ARM/Monitor/temperature.dat

date +%H:%M:%S.%N >> $saida_file
echo -n "BCPU:" >> $saida_file
cat /sys/devices/virtual/thermal/thermal_zone0/temp >> $saida_file
echo -n "MCPU:" >> $saida_file
cat /sys/devices/virtual/thermal/thermal_zone1/temp >> $saida_file
echo -n "GPU:" >> $saida_file
cat /sys/devices/virtual/thermal/thermal_zone2/temp >> $saida_file
echo -n "Board:" >> $saida_file
cat /sys/devices/virtual/thermal/thermal_zone5/temp >> $saida_file 
