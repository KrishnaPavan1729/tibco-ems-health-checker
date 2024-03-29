#!/bin/bash


readonly USERNAME="tibco"
readonly SERVICE_NAME="tibemsd"
TIMESTMP=$(date +"%I:%M:%S %p")
readonly DATE=$(date +%Y-%m-%d)
readonly EMSRAMCPUUsage="/opt/tibco/navap/EMSRAMCPUUsage/"
readonly HSTNAME=$(hostname)

function EMS_statuscheck(){
ems_count=$(ps -eaf|grep ${USERNAME} | grep ${SERVICE_NAME} | grep -v grep | wc -l)
if [[ ${ems_count} -eq 0 ]]; then
echo -e "Found ${ems_count} EMS Instances on Host ${HSTNAME}."
echo -e "Hence exiting"
exit 1
else
echo -e "Found ${ems_count} EMS Instances on Host ${HSTNAME}."
echo -e "Starting Stat Collection.. "
UserService_stat_collection
fi

}

function UserService_stat_collection(){
total_ram=0
total_cpu=0

for pid in $(pgrep -u ${USERNAME} -f ${SERVICE_NAME}); do
rss=$(ps -p ${pid} -o rss=)
cpu=$(ps -p ${pid} -o %cpu=)
emsinst_url=$(grep listen $(ps -eaf|grep ${pid} | grep -v grep | grep "conf" | awk '{print $NF}') | awk '{print $NF}')
rss_mb=$(echo "scale=2; ${rss}/1024" | bc)
total_ram=$(echo "scale=2; ${total_ram} + ${rss_mb}" | bc)
total_cpu=$(echo "scale=2; ${total_cpu} + ${cpu}" | bc )
Instances_count=$(pgrep -u ${USERNAME} -f ${SERVICE_NAME} | wc -l)
done
echo -e "${TIMESTMP} [ User : ${USERNAME} ] | [ EMS Instances Count : ${Instances_count} ] | [ Total RAM Usage : ${total_ram} MB ] | [ Total CPU Usage : ${total_cpu} %
]" >> ${EMSRAMCPUUsage}/EMSRAMCPUUsage_${DATE}.log
EMSInstances_stat
}

function EMSInstances_stat(){
for pid1 in $(pgrep -u ${USERNAME} -f ${SERVICE_NAME}); do
total_ram1=0
total_cpu1=0
rss1=$(ps -p ${pid1} -o rss=)
cpu1=$(ps -p ${pid1} -o %cpu=)
emsinst_url=$(grep listen $(ps -eaf|grep ${pid1} | grep -v grep | grep "conf" | awk '{print $NF}') | awk '{print $NF}')
rss_mb1=$(echo "scale=2; ${rss1}/1024" | bc)
total_ram1=$(echo "scale=2; ${total_ram1} + ${rss_mb1}" | bc)
total_cpu1=$(echo "scale=2; ${total_cpu1} + ${cpu1}" | bc )
echo -e "${TIMESTMP} [ User : ${USERNAME} ] | [ EMS URL : ${emsinst_url} ] | [ RAM Usage : ${total_ram1} MB ] | [ CPU Usage : ${total_cpu1}% ] " >> ${EMSRAMCPUUsage}/EMSInstancesRAMCPUUsage_${DATE}.log

done

}

EMS_statuscheck
