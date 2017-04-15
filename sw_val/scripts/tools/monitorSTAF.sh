#!/bin/bash

DUT_IP=""

function check_ip()
{
    DUT_IP=`LC_ALL=C ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
    local  stat=1
    if [[ $DUT_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($DUT_IP)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

check_ip
ret_code=$?
while (($ret_code != 0)); do
    sleep 20
    check_ip
    ret_code=$?
done

DUT_HOST_NAME=`hostname`
echo "127.0.0.1       localhost.localdomain           localhost
10.239.134.238  shldejointd234.sh.intel.com     shldejointd234
${DUT_IP}       ${DUT_HOST_NAME}                ${DUT_HOST_NAME}
" > /etc/hosts

nohup /usr/local/staf/bin/STAFProc &
sleep 20
staf local ping ping
ret_code=$?
while (($ret_code != 0)); do
    echo "start staf"
    nohup /usr/local/staf/bin/STAFProc &
    sleep 20
    staf local ping ping
    ret_code=$?
done

STAF_SERVER_IP=10.239.134.238

COMMAND="echo ${DUT_IP} > /share/icg_sh_share/AUTO/DUTs/${DUT_HOST_NAME}"
staf ${STAF_SERVER_IP} process start shell command "${COMMAND}" WAIT

