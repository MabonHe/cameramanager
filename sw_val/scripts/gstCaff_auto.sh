#!/bin/bash

if [ $# -lt 1 ] ; then 
    echo "USAGE: $0 CASE_NAME" 
    exit 1; 
fi

CASE_NAME=$1
SW_VAL_ROOT=/home/root/sw_val
GST_CAFF_AUTO_APP=${SW_VAL_ROOT}/bin/gstCaffAutoTest
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${SW_VAL_ROOT}/bin

echo 'Change to execution dir ${SW_VAL_ROOT}/results'
LOG_DIR=${SW_VAL_ROOT}/results
if [ ! -d $LOG_DIR ]; then
    mkdir $LOG_DIR
fi
cd $LOG_DIR

${SW_VAL_ROOT}/scripts/tools/gen_auto_test_config.sh ${CASE_NAME}

chmod +x ${GST_CAFF_AUTO_APP}

CAMERA0_NAME=$cameraInput
if [ -z "${CAMERA0_NAME}" ]; then
    CAMERA0_NAME=imx185
fi
CAMERA1_NAME=$cameraInput2
CAMERA2_NAME=$cameraInput3
CAMERA3_NAME=$cameraInput4
COMMAND="DISPLAY=:0 ${GST_CAFF_AUTO_APP} --config=${CASE_NAME}.xml --log_level=3 --log_path=${LOG_DIR} --cam0=${CAMERA0_NAME}"
if [ ! -z "$CAMERA1_NAME" ]; then
    COMMAND="${COMMAND} --cam1=${CAMERA1_NAME}"
fi

if [ ! -z "$CAMERA2_NAME" ]; then
    COMMAND="${COMMAND} --cam2=${CAMERA2_NAME}"
fi

if [ ! -z "$CAMERA3_NAME" ]; then
    COMMAND="${COMMAND} --cam3=${CAMERA3_NAME}"
fi

if [ ! -z "$CAMERA1_NAME" ];then # for dual, we should wait longer because mondello cmd takes time. For Four, the startup time is low.
    COMMAND="${COMMAND} --preview_warm=10000"
else
    COMMAND="${COMMAND} --preview_warm=5000"
fi

##below is used to generate mondello cmd for 2 interlaced.
if [ `echo $CASE_NAME | grep -i "dual" | wc -l` -gt 0 ];then
    . ${SW_VAL_ROOT}/scripts/tools/parse_gst_case_name.sh $CASE_NAME
    . ${SW_VAL_ROOT}/scripts/tools/multi_mondello_control.sh $CAMERA_NUM
    if [ ! -z $MONDELLO_FORMAT ]; then
        echo "Get mondello script name according to resolution array \"${I_RESOLUTION[*]}\" \"${MONDELLO_FORMAT[*]}\" \"${interlace_mode[*]}\""
        get_mondello_command_arrays_according_res_array I_RESOLUTION[@] MONDELLO_FORMAT[@] interlace_mode[@]
    fi
    if [ ! -z $MONDELLO_CONTROL_NEEDED ]; then
        reconnect_to_mondello_servers
        sleep 2
    fi
fi    
echo "Command: ${COMMAND}"
eval $COMMAND &
pid=$!
if [ ! -z $MONDELLO_CONTROL_NEEDED ]; then
    send_command_arrary_to_mondello_servers
fi
wait $pid
retval=$?
if [ $retval -ne 0 ]; then
    echo "FAIL"
else
    echo "PASS"
fi
exit $retval