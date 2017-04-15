#!/bin/bash

# MONDELLO_SERVE_IP is an array , get from env
#. /etc/profile
MONDELLO_NUM=$1
declare -a MONDELLO_COMMAND_ARRAY
#I think we can default mondello devices to 2 if the arg is not passed.
if [ -z ${MONDELLO_NUM} ];then
    MONDELLO_NUM=2
fi
echo ${MONDELLO_SERVER_IP}
MONDELLO_SERVER_IP_A=(${MONDELLO_SERVER_IP//\:/ })
i=0
for server_ip in ${MONDELLO_SERVER_IP_A[*]}
do
    i=$((i+1))
    echo "Mondello server IP $i address: ${server_ip}"
done

if [ ! $i -eq ${MONDELLO_NUM} ];then
    RESULT="FAIL"
    DESCRIPTION="Error, this case need ${MONDELLO_NUM} mondello devices, but $i are found. Please export MONDELLO_SERVER_IP=ip1:ip${MONDELLO_NUM} in env first."
    echo "Test Case: ${CASE_NAME}"
    echo "Result: $RESULT"
    echo "Description: $DESCRIPTION"
    exit -1
fi

MONDELLO_CONTROL_NEEDED=1
. /home/root/sw_val/scripts/tools/mondello_control_helper.sh

function get_mondello_command_arrays_according_res_array(){
    # those array can be passed through arguments. Or will used the array in shell environment.
    if [ $# -eq 3 ];then
        I_RESOLUTION=("${!1}")
        I_PIXEL_FORMAT=("${!2}")
        IS_INTERLACED=("${!3}")
    fi
    local i=0
    for server_ip in ${MONDELLO_SERVER_IP_A[*]}
    do
        resolution=${I_RESOLUTION[$i]}
        iformat=${I_PIXEL_FORMAT[$i]}
        is_interlaced=${IS_INTERLACED[$i]}
        get_mondello_command_according_res_info $resolution $iformat $is_interlaced
        echo "Get MONDELLO_COMMAND=${MONDELLO_COMMAND}"
        MONDELLO_COMMAND_ARRAY[$i]=${MONDELLO_COMMAND}
        i=$((i+1))
    done
    echo "MONDELLO_COMMAND_ARRAY=${MONDELLO_COMMAND_ARRAY[*]}"
}

function send_command_arrary_to_mondello_servers(){
    local i=0
    declare -a m_pids
    for server_ip in ${MONDELLO_SERVER_IP_A[*]}
    do
        local mondello_cmd=${MONDELLO_COMMAND_ARRAY[$i]}
        echo "mondello server_ip=$server_ip, mondello_cmd=$mondello_cmd"
        send_command_to_mondello_server ${server_ip} ${mondello_cmd} &
        m_pids[$i]=$!
        i=$((i+1))
    done
    wait ${m_pids[*]}
    echo "send commands to mondello servers done!"
}

function reconnect_to_mondello_servers(){
    local i=0
    declare -a m_pids
    for server_ip in ${MONDELLO_SERVER_IP_A[*]}
    do
        local mondello_cmd=${MONDELLO_COMMAND_ARRAY[$i]}
        reconnect_to_mondello_server ${server_ip} ${mondello_cmd} &
        m_pids[$i]=$!
        i=$((i+1))
    done
    wait ${m_pids[*]}
    echo "reconnect to mondello servers done!"
}