#!/bin/bash

file=/home/nvidia/Testes_ARM/Monitor/temperature.dat

date +%H:%M:%S.%N >> $file
echo -n "BCPU:" >> $file
cat /sys/devices/virtual/thermal/thermal_zone0/temp >> $file
echo -n "MCPU:" >> $file
cat /sys/devices/virtual/thermal/thermal_zone1/temp >> $file
echo -n "GPU:" >> $file
cat /sys/devices/virtual/thermal/thermal_zone2/temp >> $file
echo -n "Board:" >> $file
cat /sys/devices/virtual/thermal/thermal_zone5/temp >> $file 
