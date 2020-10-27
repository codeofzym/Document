#!/bin/sh
FILE_NAME="meminfo.log"
FOLDER="/app/sd/log"
#FOLDER=`pwd`
LOG_PATH=${FOLDER}/${FILE_NAME}
RUN_TIME=60
echo ---------------------------------------------------------------------------------- > ${LOG_PATH}
echo "MemAvailable≈MemFree+Buffers+Cached" >> ${LOG_PATH}
let TIME=`date +%s`%1000
echo "Start Time:"`date "+%Y-%m-%d %H:%M:%S"`.$TIME >> ${LOG_PATH}
if [ $# == 1 ]
then
    if [ $1 -gt 0 ] 
    then
        RUN_TIME=$1
    fi
fi
echo "run time is "${RUN_TIME}" min" >> ${LOG_PATH}
#echo $TIME
echo -n "                            " >> ${LOG_PATH}
`cat /proc/meminfo | awk '{a[NR] = $1}END{for(i = 1; i < 6; i++){printf "%-16s",a[i]}}' >> ${LOG_PATH}`
echo >> ${LOG_PATH}
i=1
while [ $i -le $RUN_TIME ]
do
let TIME=`date +%s`%1000
TIME=`date "+%Y-%m-%d %H:%M:%S"`.$TIME
echo -n [$TIME]"   " >> ${LOG_PATH}
`cat /proc/meminfo | awk '{a[NR] = $2}END{for(i = 1; i < 6; i++){printf "%-16s",a[i]}}' >> ${LOG_PATH}`
echo >> ${LOG_PATH}
let i++
sleep 1m
done
echo "END Time:"`date "+%Y-%m-%d %H:%M:%S"`.$[`date +%s`%1000] >> ${LOG_PATH}

