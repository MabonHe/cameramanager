#!/bin/sh
SW_VAL_ROOT=/home/root/sw_val
RESULT="Success"

echo -e "\nSelect which camera stream interlaced mode. The other one is progressive."
echo -e "Please select in 10s. The default is the 1st option"
echo -e "1. the first camera \n2. the second camera"
read -t 10 -p "" ans

case $ans in 
    1)
        interlaced_cam=0
        progressive_cam=1
        ;;
    2)
        interlaced_cam=1
        progressive_cam=0
        ;;
    *)
        interlaced_cam=0
        progressive_cam=1
        ;;
esac

echo -e "Select the first camera's format:\n1. UYVY \n2. RGB888 \n3. RGB565 \n4. YUYV \n5. CVBS"
read -t 10 -p "" ans
case $ans in
    1)
        format_0=UYVY
        ;;
    2)
        format_0=RGB888
        ;;
    3)
        format_0=RGB565
        ;;
    4)
        format_0=YUYV
        ;;
    5)
        format_0=CVBS
        ;;    
    *)
        format_0=CVBS
        ;;
esac

echo -e "Select first camera's resolution: \n1. 1920x1080 \n2. 1280x720 \n3. 720x576 \n4. 640x480"
read -t 10 -p "" ans
case $ans in
    1)
        resolution_0=1920x1080
        ;;
    2)
        resolution_0=1280x720
        ;;
    3)
        resolution_0=720x576
        ;;
    4)
        resolution_0=640x480
        ;;
    *)
        resolution_0=720x576
        ;;    
esac
echo -e "Select first camera's iomode: \n1. useptr \n2. mmap \n3. dmaimport"
read -t 10 -p "" ans
case $ans in
    1)
        iomode_0=V4L2_MEMORY_USERPTR
        ;;
    2)
        iomode_0=V4L2_MEMORY_MMAP
        ;;
    3)
        iomode_0=V4L2_MEMORY_DMABUF
        ;;
    *)
        iomode_0=V4L2_MEMORY_USERPTR
        ;;    
esac
echo -e "Select the second camera's format:\n1. UYVY \n2. RGB888 \n3. RGB565 \n4. YUYV \n5. CVBS"
read -t 10 -p "" ans
case $ans in
    1)
        format_1=UYVY
        ;;
    2)
        format_1=RGB888
        ;;
    3)
        format_1=RGB565
        ;;
    4)
        format_1=YUYV
        ;;
    5)
        format_1=CVBS
        ;;    
    *)
        format_1=UYVY
        ;;
esac

echo -e "Select second camera's resolution: \n1. 1920x1080 \n2. 1280x720 \n3. 720x576 \n4. 640x480"
read -t 10 -p "" ans
case $ans in
    1)
        resolution_1=1920x1080
        ;;
    2)
        resolution_1=1280x720
        ;;
    3)
        resolution_1=720x576
        ;;
    4)
        resolution_1=640x480
        ;;
    *)
        resolution_1=720x576
        ;;    
esac
echo -e "Select second camera's iomode: \n1. useptr \n2. mmap \n3. dmaimport"
read -t 10 -p "" ans
case $ans in
    1)
        iomode_1=V4L2_MEMORY_USERPTR
        ;;
    2)
        iomode_1=V4L2_MEMORY_MMAP
        ;;
    3)
        iomode_1=V4L2_MEMORY_DMABUF
        ;;
    *)
        iomode_1=V4L2_MEMORY_USERPTR
        ;;    
esac
echo -e "Your finial choice:\n camera_0 : format=${format_0} resolution=${resolution_0} iomode=${iomode_0}\n camera_1 : format=${format_1} resolution=${resolution_1} iomode=${iomode_1}\n Camera ${interlaced_cam} is in interlaced mode\n Camera ${progressive_cam} is progressive."

# get mondello format
IOMODE=(${iomode_0} ${iomode_1})
FORMAT=(${format_0} ${format_1})
RESOLUTIONS=(${resolution_0} ${resolution_1})
if [ "${interlaced_cam}" == "0" ]; then
    interlace_mode=(true false)
else
    interlace_mode=(false true)
fi
declare -a WIDTH
declare -a HEIGHT
WIDTH[0]=${resolution_0%%x*}
WIDTH[1]=${resolution_1%%x*}
HEIGHT[0]=${resolution_0##*x}
HEIGHT[1]=${resolution_1##*x}

for ((i=0; i<${#FORMAT[@]}; i++))
do
    if [ "${FORMAT[$i]}" == "UYVY" ]; then
        if [ "$cameraInput" == "mondello" ]; then
            FORMATS_V4L2[$i]=V4L2_PIX_FMT_UYVY
            MONDELLO_FORMAT[$i]=yuv422
        fi
    elif [ "${FORMAT[$i]}" == "YUYV" ]; then
        if [ "$cameraInput" == "mondello" ]; then
            FORMATS_V4L2[$i]=V4L2_PIX_FMT_YUYV
            MONDELLO_FORMAT[$i]=yuv422_yuyv
       
        fi
    elif [ "${FORMAT[$i]}" == "CVBS" ]; then
        if [ "$cameraInput" == "mondello" ]; then
            FORMAT[$i]=UYVY
            FORMATS_V4L2[$i]=V4L2_PIX_FMT_UYVY
            MONDELLO_FORMAT[$i]=cvbs
       
        fi  
    elif [ "${FORMAT[$i]}" == "RGB888" ]; then
        FORMATS_V4L2[$i]=V4L2_PIX_FMT_BGR24
        if [ "$cameraInput" == "mondello" ]; then
            MONDELLO_FORMAT[$i]=rgb24
        fi
    elif [ "${FORMAT[$i]}" == "RGB565" ] ; then
        FORMATS_V4L2[$i]=V4L2_PIX_FMT_RGB565
        if [ "$cameraInput" == "mondello" ]; then
            MONDELLO_FORMAT[$i]=rgb565
        fi
    fi
done

echo 'Change to execution dir ${SW_VAL_ROOT}/results'
LOG_DIR=${SW_VAL_ROOT}/results
if [ ! -d $LOG_DIR ]; then
    mkdir $LOG_DIR
fi

cd $LOG_DIR

. ${SW_VAL_ROOT}/scripts/tools/multi_mondello_control.sh 2

if [ ! -z ${MONDELLO_CONTROL_NEEDED} ]; then
    echo "Get mondello script name according to resolution array \"${RESOLUTIONS[*]}\" \"${MONDELLO_FORMAT[*]}\" \"${interlace_mode[*]}\""
    get_mondello_command_arrays_according_res_array RESOLUTIONS[@] MONDELLO_FORMAT[@] interlace_mode[@]
fi

camrealinput="$cameraInput"
camrealinput2="$cameraInput2"
camrealinput_a=($cameraInput $cameraInput2)
if [ -z ${camrealinput} ] || [ -z ${camrealinput2} ];then
    echo "cameraInput or cameraInput2 is null! please export in /etc/profile"
    exit -1
fi
declare -a FILED_ORDER
if [ ${interlace_mode[0]} == false ];then
    FILED_ORDER=(V4L2_FIELD_NONE V4L2_FIELD_ALTERNATE)
    HEIGHT[1]=`expr ${HEIGHT[1]} / 2`
else
    FILED_ORDER=(V4L2_FIELD_ALTERNATE V4L2_FIELD_NONE)
    HEIGHT[0]=`expr ${HEIGHT[0]} / 2`
fi
echo "Media config : . ${SW_VAL_ROOT}/scripts/media_config/1P_1I_mipi.sh FORMAT[@] WIDTH[@] HEIGHT[@] IS_INTERLACED[@]" 
. ${SW_VAL_ROOT}/scripts/media_config/adv7481_dual_interlaced_progressive_mipi.sh FORMAT[@] WIDTH[@] HEIGHT[@] interlace_mode[@]

i=0
for dev_name in ${DEV_NAME[*]}
do
    if [ -z ${dev_name} ];then
        echo "Camera $i is not initialized!"
        exit -1
    fi
    echo "Camera $i is initialized! DEV_NAME_$i=${dev_name}"
    i=$((i+1))
done
 
if [ ! -z $MONDELLO_CONTROL_NEEDED ]; then
    reconnect_to_mondello_servers
    sleep 3
fi

declare -a APP_LOG_FILE_NAME
chmod +x ${SW_VAL_ROOT}/bin/ipu4_v4l2_test
APP_LOG_FILE_BASE_NAME=1P1I_CAM0_${FILED_ORDER[0]}_${RESOLUTIONS[0]}_${FORMAT[0]}_CAM1_${FILED_ORDER[1]}_${RESOLUTIONS[1]}_${FORMAT[1]}_
GTEST_CASE_FILTER_long=*.CI_PRI_IPU4_IOCTL_Capture_Frame_6000_FPS_60
GTEST_CASE_FILTER_short=*.CI_PRI_IPU4_IOCTL_Capture_Frame_5
echo 'Run test apps'
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

declare -a pids
declare -a export_device
declare -a gtest_filter
declare -a v4l2_cmd

function start_test(){
    i=0
    for dev_name in ${DEV_NAME[*]}
    do
        is_block_mode=noblock
        field_order=${FILED_ORDER[$i]}
        memory_type=${IOMODE[$i]}
        pixel_format=${FORMATS_V4L2[$i]}
        width=${WIDTH[$i]}
        height=${HEIGHT[$i]}
        APP_LOG_FILE_NAME[$i]="${APP_LOG_FILE_BASE_NAME}_CAM$i.log"
        DUMP_PREFIX[$i]="${APP_LOG_FILE_BASE_NAME}_CAM${i}_"
        if [ "${memory_type}" == "V4L2_MEMORY_DMABUF" ];then
            echo "Choosing a device other than ${DEV_NAME[*]} ${export_device[*]}"
            for j in $(seq 0 20)
            do
                export_name="/dev/video${j}"
                if [ $(echo ${DEV_NAME[*]} | grep "${export_name}" | wc -l) -eq 0 ] && [ $(echo ${export_device[*]} | grep "${export_name}" | wc -l) -eq 0 ];then
                    echo "export device for camera ${i} is ${export_name}"
                    export_device[$i]=${export_name}
                    break
                fi
            done
        else
            export_device[$i]=
        fi
        
        if [ "${width[$i]}" = "720" -a "${height[$i]}" = "288" ];then
                gtest_filter[$i]=${gtest_filter[$i]/FPS_60/FPS_50}
        fi
        
        echo "App command: ${SW_VAL_ROOT}/bin/ipu4_v4l2_test --gtest_filter=${gtest_filter[$i]} -d=$dev_name -i=$is_block_mode -f=$field_order \
        -m=$memory_type -p=$pixel_format -w=$width -h=$height -c="pwd" -r=${DUMP_PREFIX[$i]} -export_device=${export_device[$i]}"
        v4l2_cmd[$i]="${SW_VAL_ROOT}/bin/ipu4_v4l2_test --gtest_filter=${gtest_filter[$i]} -d=$dev_name -i=$is_block_mode -f=$field_order \
        -m=$memory_type -p=$pixel_format -w=$width -h=$height -c="pwd" -r=${DUMP_PREFIX[$i]} -export_device=${export_device[$i]} > ${APP_LOG_FILE_NAME[$i]} &"
        i=$((i+1))
    done
    i=0
    for cmd in ${v4l2_cmd[*]}
    do
        if [ "${gtest_filter[$i]}" = "${GTEST_CASE_FILTER_long}" ];then    
            echo "Start the long cmd:"
            echo "${v4l2_cmd[$i]}"
            eval ${v4l2_cmd[$i]}
            long_pid=$!
            cam_long=$i
            send_command_to_mondello_server ${MONDELLO_SERVER_IP_A[$i]} ${MONDELLO_COMMAND_ARRAY[$i]}
            j=$((1-$i))
            for q in $(seq 0 10)
            do
                echo "Start $q cycle for short cmd"
                echo "${v4l2_cmd[$j]}"
                eval ${v4l2_cmd[$j]}
                send_command_to_mondello_server ${MONDELLO_SERVER_IP_A[$j]} ${MONDELLO_COMMAND_ARRAY[$j]}
                short_pid=$!
                wait ${short_pid}
                if [ $? -ne 0  ]; then
                    RESULT="FAIL"
                    DESCRIPTION="Error, please refer to ${APP_LOG_FILE_BASE_NAME}_CAM$j.log."
                fi
                LOG=${APP_LOG_FILE_NAME[$j]}
                if [ ! -f ${LOG} ];then
                    RESULT="TBD"
                    DESCRIPTION="Log file ${LOG} not found."
                    break
                else
                    echo "${LOG}:"
                    cat ${LOG}
                    grep "\[  FAILED  \] 1 test" ${LOG}
                    if [ $? -eq 0 ]; then
                        RESULT="FAIL"
                        DESCRIPTION="Error, please refer to ${LOG}"
                        break
                    fi
                    rm -f ${LOG}
                fi
            done
            i=$(($i+1))
        else    
            i=$(($i+1))
        fi
    done

    wait ${long_pid}

    if [ $? -ne 0  ]; then
        RESULT="FAIL"
        DESCRIPTION="Error, please refer to ${APP_LOG_FILE_BASE_NAME}_CAM$i.log."
    fi
    LOG=${APP_LOG_FILE_NAME[${cam_long}]}
    if [ ! -f ${LOG} ];then
        RESULT="TBD"
        DESCRIPTION="Log file ${LOG} not found."
    else
        echo "${LOG}:"
        cat ${LOG}
        grep "\[  FAILED  \] 1 test" ${LOG}
        if [ $? -eq 0 ]; then
            RESULT="FAIL"
            DESCRIPTION="Error, please refer to ${LOG}"
        fi
        rm -f ${LOG}
    fi
}
gtest_filter=(${GTEST_CASE_FILTER_long} ${GTEST_CASE_FILTER_short})
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "Start cycling with gtest filters ${gtest_filter[*]}"
start_test
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
gtest_filter=(${GTEST_CASE_FILTER_short} ${GTEST_CASE_FILTER_long})
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "Start cycling with gtest filters ${gtest_filter[*]}"
start_test
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
chmod +x ${SW_VAL_ROOT}/scripts/tools/check_dmesg_error.sh
${SW_VAL_ROOT}/scripts/tools/check_dmesg_error.sh

echo "Test Case: $CASE_NAME"
echo "Result: $RESULT"
echo "Description: $DESCRIPTION"

if [ $RESULT == "PASS" ]; then
    exit 0
else
    exit -1
fi
 
