#!/bin/sh
RUN_TIME=10
if [ $# -ge 1 ]
then
    if [ $1 -gt 0 ] 
    then
        RUN_TIME=$1
    fi
fi

LOG_PATH="/app/sd/log/let_auto_test.log"
if [ $# -ge 2 ]
then
    LOG_PATH=$2
fi

echo ---------------------------------------------------------------------------------- > ${LOG_PATH}
let TIME=`date +%s`%1000
echo "Start Time:"`date "+%Y-%m-%d %H:%M:%S"`.$TIME >> ${LOG_PATH}

i=0
while [ $i -le $RUN_TIME ]
do
`himm 0x1207002c 0x5` >> ${LOG_PATH}
sleep 0.5
`himm 0x1207002c 0x4` >> ${LOG_PATH}
sleep 0.5
let i++
done

echo ---------------------------------------------------------------------------------- >> ${LOG_PATH}
let TIME=`date +%s`%1000
echo "End Time:"`date "+%Y-%m-%d %H:%M:%S"`.$TIME >> ${LOG_PATH}
