#!/bin/bash

function Help {
	echo "
Options to be used
	-p The process name
	-w The warning for CPU percentage
	-c The critical for CPU percentage
	-x The warning for Memory percentage
	-y The critica for Memory percentage

Exit Code
	0 - OK
	1 - WARNING
	2 - CRITICAL
	3 - UNKNOWN
	"

	exit 3
}

function Status {
	case $EXITCODE in
			0) EXITSTATUS="OK" ;;
	        1) EXITSTATUS="WARNING" ;;
	        2) EXITSTATUS="CRITICAL";;
	        3) EXITSTATUS="UNKNOWN" ;;
	esac
}

while getopts "p:w:c:x:y:" OPTION
do
	case $OPTION in
		p) PROCESS=$OPTARG ;;
		w) CPU_WARNING=$OPTARG ;;
		c) CPU_CRITICAL=$OPTARG ;;
		x) MEM_WARNING=$OPTARG ;;
		y) MEM_CRITICAL=$OPTARG ;;
	esac
done

if [[ $PROCESS == "" ]] || [[ $CPU_WARNING == "" ]] || [[ $CPU_CRITICAL == "" ]] || [[ $MEM_WARNING == "" ]] || [[ $MEM_CRITICAL == "" ]]; then
	Help
fi

NPROC_OUTPUT=`nproc`
TOP_OUTPUT=`top -n1 -b | grep $PROCESS`
IOTOP_OUTPUT=`iotop -n 2 | grep $PROCESS`

EXITCODE=0
EXITSTATUS=""
CPU=0.0
MEM=0.0R
RSS=0.0
VSZ=0.0
RD_DSK=0.0
WR_DSK=0.0
COUNT=0

CPU=$(echo $TOP_OUTPUT | awk '{print $9}')
CPU=$(echo "print ${CPU/,/.} / $NPROC_OUTPUT" | python)
MEM=$(echo $TOP_OUTPUT | awk '{print $10}')
RSS=$(echo $TOP_OUTPUT | awk '{print $6}')
VSZ=$(echo $TOP_OUTPUT | awk '{print $5}')


for LINE2 in ${IOTOP_OUTPUT}; do
	RD_DSK=$(echo $LINE2 | awk '{print $4}')
	WR_DSK=$(echo $LINE2 | awk '{print $5}')
done


CPU_IN_WARNING=$(awk 'BEGIN{ print "'$CPU'">="'$CPU_WARNING'" }')
CPU_IN_CRITICAL=$(awk 'BEGIN{ print "'$CPU'">="'$CPU_CRITICAL'" }')
MEM_IN_WARNING=$(awk 'BEGIN{ print "'$MEM'">="'$MEM_WARNING'" }')
MEM_IN_CRITICAL=$(awk 'BEGIN{ print "'$MEM'">="'$MEM_CRITICAL'" }')

if [ "$CPU_IN_WARNING" -eq 1 ] && [ "$CPU_IN_CRITICAL" -eq 0 ] || [ "$MEM_IN_WARNING" -eq 1 ] && [ "$MEM_IN_CRITICAL" -eq 0 ]; then
  EXITCODE=1
  Status
elif [ "$CPU_IN_CRITICAL" -eq 1 ] || [ "$MEM_IN_CRITICAL" -eq 1 ]; then
  EXITCODE=2
  Status
else
	EXITCODE=0
	Status
fi

perftada="Process: ${PROCESS} CPU: ${CPU}% (${NPROC_OUTPUT} Processors)  MEM: ${MEM}%  RSS: ${RSS} Kb  VSZ: ${VSZ} Kb RD_DSK: ${RD_DSK} B/s WR_DSK: ${WR_DSK} B/s"
echo "Status[$EXITSTATUS] | ${perftada}"

exit $EXITCODE
