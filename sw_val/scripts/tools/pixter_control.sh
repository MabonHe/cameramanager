#!/bin/bash

PIXTER_CONTROL_NEEDED=1

get_pixter_command_by_casename(){
    KEY_WORDS=${CASE_NAME##*FOUR_CAMERA_}
    KEY_WORDS=${KEY_WORDS//YUV422/YUY2}
    KEY_WORDS=${KEY_WORDS//UYVY/YUY2}
    DATA="C:\\VirtualChannel\\VC_FOUR_CAMERA_${KEY_WORDS}.bin"
    PIXTER_CMD="data=${DATA} start"
    echo "PIXTER_CMD:${PIXTER_CMD}"
}

send_command_to_pixter(){
    if [ -z "${PIXTER_IP}" ];then
        echo "PIXTER_IP is not set in env!"
        exit -1
    else
        echo ${PIXTER_CMD} > /dev/tcp/${PIXTER_IP}/24680
        if [ $? -eq 0 ];then
            echo "Command ${PIXTER_CMD} sent to server ${PIXTER_IP} successfully!"
        else
            echo "Command ${PIXTER_CMD} sent to server ${PIXTER_IP} failed!"
            exit -1
        fi
    fi
}
reset_stop_pixter(){
    if [ -z "${PIXTER_IP}" ];then
        echo "PIXTER_IP is not set in env!"
        exit -1
    else
        echo "reset" > /dev/tcp/${PIXTER_IP}/24680
        sleep 3
        echo "stop" > /dev/tcp/${PIXTER_IP}/24680
        if [ $? -eq 0 ];then
            echo "Reset and stop server ${PIXTER_IP} successfully!"
        else
            echo "Reset and stop server server ${PIXTER_IP} failed!"
        fi
    fi
}