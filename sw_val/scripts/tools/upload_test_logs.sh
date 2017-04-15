#!/bin/bash
test_type=$1
build_number=$2
dut_name=$3
uuid=$4

SERVER_IP=10.239.132.71
SERVER_LOG_ROOT=/volume1/icg_sh_share/AUTO/Logs

if [ -z "$build_number" ] || [ -z "$dut_name" ] || [ -z "$uuid" ]; then
    echo "upload_test_logs.sh build_config build_number dut_name uuid"
    exit -1
fi

if [ "$test_type" != "linux_dev_smoke" ] && [ "$test_type" != "linux_pit" ] && [ "$test_type" != "linux_pit_lite" ] && [ "$test_type" != "linux_weekly" ]; then
    echo "Test type is not correct! ${test_type}"
    exit -1
fi

# Remove old XSTAF tmp std log 
find /home/root/XSTAF/ -ctime +1 -type d | xargs rm -rf

SW_VAL_ROOT=/home/root/sw_val
SERVER_LOG_PATH=root@${SERVER_IP}:${SERVER_LOG_ROOT}/${test_type}/${build_number}/${dut_name}/${uuid}

LOCAL_LOG_PATH=${SW_VAL_ROOT}/results

cp -r ${SW_VAL_ROOT}/scripts/tools/.ssh ~
chmod 600 ~/.ssh/id_rsa

ssh root@${SERVER_IP} mkdir -p ${SERVER_LOG_ROOT}/${test_type}/${build_number}/${dut_name}/${uuid}
ssh root@${SERVER_IP} chmod 777 ${SERVER_LOG_ROOT}/${test_type}/${build_number}/${dut_name} -R

chmod 777 ${SW_VAL_ROOT}/build/*.txt
scp ${SW_VAL_ROOT}/build/*.txt ${SERVER_LOG_PATH}

scp -r ${LOCAL_LOG_PATH} ${SERVER_LOG_PATH}

exit $?