#!/bin/bash

IPMI_TEMP_OUTPUT=`/usr/sbin/ipmi-sensors`

### Power and Temperature ###
CURRENT_TEMP1=$(echo $IPMI_TEMP_OUTPUT | /usr/sbin/ipmi-sensors | grep CPU1 | grep Temp | awk '{print $8}')
CURRENT_TEMP2=$(echo $IPMI_TEMP_OUTPUT | /usr/sbin/ipmi-sensors | grep CPU2 | grep Temp | awk '{print $8}')

echo "$CURRENT_TEMP1  $CURRENT_TEMP2" >> tempetature.dat
