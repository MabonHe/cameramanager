#!/bin/bash


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
        format_0=YUY2
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
        iomode_0=userptr
        ;;
    2)
        iomode_0=mmap
        ;;
    3)
        iomode_0=dma_import
        ;;
    *)
        iomode_0=userptr
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
        format_1=YUY2
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
        iomode_1=userptr
        ;;
    2)
        iomode_1=mmap
        ;;
    3)
        iomode_1=dma_import
        ;;
    *)
        iomode_1=userptr
        ;;    
esac
echo -e "Your finial choice:\n camera_0 : format=${format_0} resolution=${resolution_0} iomode=${iomode_0}\n camera_1 : format=${format_1} resolution=${resolution_1} iomode=${iomode_1}\n Camera ${interlaced_cam} is in interlaced mode\n Camera ${progressive_cam} is progressive."

# get mondello format

FORMATS=(${format_0} ${format_1})
RESOLUTIONS=(${resolution_0} ${resolution_1})
IOMODE=(${iomode_0} ${iomode_1})
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

for ((i=0; i<${#FORMATS[@]}; i++))
do
    if [ "${FORMATS[$i]}" == "UYVY" ]; then
        if [ "$cameraInput" == "mondello" ]; then
            FORMATS_V4L2[$i]=V4L2_PIX_FMT_UYVY
            MONDELLO_FORMAT[$i]=yuv422
        fi
    elif [ "${FORMATS[$i]}" == "YUYV" ] || [ "${FORMATS[$i]}" == "YUY2" ]; then
        if [ "$cameraInput" == "mondello" ]; then
            FORMATS_V4L2[$i]=V4L2_PIX_FMT_YUYV
            MONDELLO_FORMAT[$i]=yuv422_yuyv
            FORMATS[$i]=YUY2
        fi
    elif [ "${FORMATS[$i]}" == "CVBS" ]; then
        if [ "$cameraInput" == "mondello" ]; then
            FORMATS[$i]=UYVY
            FORMATS_V4L2[$i]=V4L2_PIX_FMT_UYVY
            MONDELLO_FORMAT[$i]=cvbs
       
        fi  
    elif [ "${FORMATS[$i]}" == "RGB888" ]; then
        FORMATS_V4L2[$i]=V4L2_PIX_FMT_BGR24
        if [ ${interlace_mode[$i]} == 'true' ]; then
            FORMATS[$i]=RGBx
        else
            FORMATS[$i]=BGR
        fi
        
        if [ "$cameraInput" == "mondello" ]; then
            MONDELLO_FORMAT[$i]=rgb24
        fi
    elif [ "${FORMATS[$i]}" == "RGB565" ] ; then
        FORMATS_V4L2[$i]=V4L2_PIX_FMT_RGB565
        if [ ${interlace_mode[$i]} == 'true' ]; then
            FORMATS[$i]=RGBx
        else
            FORMATS[$i]=RGB16
        fi
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
if [ -z ${camrealinput} ] || [ -z ${camrealinput2} ];then
    echo "cameraInput or cameraInput2 is null! please export in /etc/profile"
    exit -1
fi
declare -a camrealinput_a=(${camrealinput} ${camrealinput2})
printfps=false
num_buffers=-1
GST_COMMAND="DISPLAY=:0 gst-launch-1.0"
for((i=1; i>=0; i--))
do
    GST_COMMAND="${GST_COMMAND} icamerasrc device-name=${camrealinput_a[$i]} printfps=${printfps} num-buffers=${num_buffers} io-mode=${IOMODE[${i}]}"
    if [ ${interlace_mode[${i}]} == true ];then
        GST_COMMAND="${GST_COMMAND} interlace-mode=alternate deinterlace_method=sw_bob"
    fi
    if [ ${FORMATS[$i]} == RGB888 ] || [ ${FORMATS[$i]} == RGB565 ] || [ ${FORMATS[$i]} == RGB16 ]|| [ ${FORMATS[$i]} == BGR ];then
        sink="videoconvert ! ximagesink"
    else
        sink="vaapipostproc ! vaapisink"
    fi    
    GST_COMMAND="${GST_COMMAND} ! video/x-raw,format=${FORMATS[$i]},width=${WIDTH[$i]},height=${HEIGHT[$i]} ! ${sink}"
done
LOG_FILE_NAME=1P1I_CAM0_${FILED_ORDER[0]}_${RESOLUTIONS[0]}_${FORMAT[0]}_CAM1_${FILED_ORDER[1]}_${RESOLUTIONS[1]}_${FORMAT[1]}_    
GST_COMMAND="${GST_COMMAND} > ${LOG_FILE_NAME}"
if [ ! -z $MONDELLO_CONTROL_NEEDED ]; then
    reconnect_to_mondello_servers
    sleep 5
fi
echo "Execute Command: ${GST_COMMAND}"
eval $GST_COMMAND &
pid=$!
if [ ! -z $MONDELLO_CONTROL_NEEDED ]; then
    sleep 10
    send_command_arrary_to_mondello_servers
fi
wait $pid
retval=$?

  