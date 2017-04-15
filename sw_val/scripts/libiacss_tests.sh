#!/bin/bash

if [ $# -lt 1 ] ; then 
    echo "USAGE: $0 CASE_NAME" 
    exit 1; 
fi

CASE_NAME=$1
SW_VAL_ROOT=/home/root/sw_val
TEST_APP=${SW_VAL_ROOT}/bin/libiacss_tests
FRAME_BIN_PATH=/tmp/input_raw_images
FRAME_BIN_NAME=frame_256x256_512_12_0.bin

echo 'Change to execution dir ${SW_VAL_ROOT}/results'
LOG_DIR=${SW_VAL_ROOT}/results
if [ ! -d $LOG_DIR ]; then
    mkdir $LOG_DIR
fi
cd $LOG_DIR

# frame file
if [ ! -d "$FRAME_BIN_PATH" ]; then  
    mkdir "$FRAME_BIN_PATH"  
fi
if [ ! -f "${FRAME_BIN_PATH}/${FRAME_BIN_NAME}" ]; then  
    cp ${SW_VAL_ROOT}/bin/${FRAME_BIN_NAME} ${FRAME_BIN_PATH}/${FRAME_BIN_NAME}
fi

chmod +x ${TEST_APP}

COMMAND="${TEST_APP} --gtest_filter=${CASE_NAME}"
echo "Command: ${COMMAND}"
eval $COMMAND

retval=$?
if [ $retval -ne 0 ]; then
    echo "FAIL"
else
    echo "PASS"
fi
exit $retval