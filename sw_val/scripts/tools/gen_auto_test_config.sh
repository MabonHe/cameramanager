#!/bin/bash

CASE_NAME=$1
CASE_CONFIG=""

function case_0_begin()
{
    local case_id=$1
    CASE_CONFIG="${CASE_CONFIG}\n<${case_id}>" 
}

function case_0_end()
{
    local case_id=$1
    CASE_CONFIG="${CASE_CONFIG}\n</${case_id}>" 
}

function info_1_full()
{
    local case_name=$1
    local case_description=$2
    CASE_CONFIG="${CASE_CONFIG}\n\t<case_info case_name=\"${case_name}\" discription=\"${case_description}\" />" 
}

function stress_1_full()
{
    local loop_count=$1
    CASE_CONFIG="${CASE_CONFIG}\n\t<stress loop_count=\"${loop_count}\" />"
}

function config_1_begin()
{
    local index=$1
    CASE_CONFIG="${CASE_CONFIG}\n\t<config${index}>"
}

function config_1_end()
{
    local index=$1
    CASE_CONFIG="${CASE_CONFIG}\n\t</config${index}>"
}

function camera_2_begin()
{
    local index=$1
    local duration=$2
    CASE_CONFIG="${CASE_CONFIG}\n\t\t<camera${index} duration=\"${duration}\">"
}

function camera_2_end()
{
    local index=$1
    CASE_CONFIG="${CASE_CONFIG}\n\t\t</camera${index}>"
}

function camera_common_settings_3_full()
{
    local width=$1
    local height=$2
    local pixelformat=$3
    local io_mode=$4
    local printfps=$5
    local capture_mode=$6
    local num_buffers=$7
    local interlace_mode=$8
    local deinterlace_method=$9
    local framerate=${10}
    
    if [ -z "${width}" ]; then
        width=1920
    fi
    
    if [ -z "${height}" ]; then
        height=1080
    fi
    
    if [ -z "${pixelformat}" ]; then
        pixelformat=NV12
    fi
    
    if [ -z "${num_buffers}" ]; then
        num_buffers=-1
    fi
    
    if [ -z "${printfps}" ]; then
        printfps=0
    fi
    
    if [ -z "${capture_mode}" ]; then
        capture_mode=video
    fi
    
    if [ -z "${io_mode}" ]; then
        io_mode=MMAP
    fi
    
    if [ -z "${interlace_mode}" ]; then
        interlace_mode=any
    fi
    
    if [ -z "${deinterlace_method}" ]; then
        deinterlace_method=none
    fi
    
    CASE_CONFIG="${CASE_CONFIG}\n\t\t\t<common_settings"
    CASE_CONFIG="${CASE_CONFIG} width=\"${width}\""
    CASE_CONFIG="${CASE_CONFIG} height=\"${height}\""
    CASE_CONFIG="${CASE_CONFIG} pixelformat=\"${pixelformat}\""
    CASE_CONFIG="${CASE_CONFIG} num-buffers=\"${num_buffers}\""
    CASE_CONFIG="${CASE_CONFIG} printfps=\"${printfps}\""
    CASE_CONFIG="${CASE_CONFIG} capture-mode=\"${capture_mode}\""
    CASE_CONFIG="${CASE_CONFIG} io-mode=\"${io_mode}\""
    CASE_CONFIG="${CASE_CONFIG} interlace-mode=\"${interlace_mode}\""
    CASE_CONFIG="${CASE_CONFIG} deinterlace-method=\"${deinterlace_method}\""
    if [ ! -z "${framerate}" ]; then
        CASE_CONFIG="${CASE_CONFIG} framerate=\"${framerate}\""
    fi
    CASE_CONFIG="${CASE_CONFIG} />"
}

function camera_3a_settings_3_full()
{
    local scene_mode=$1
    local wdr_level=$2
    local awb_mode=$3
    local ae_mode=$4
    local saturation=$5
    local iris_level=$6
    local exposure_time=$7
    local gain=$8
    local ev=$9
    local sharpness=${10}
    local cct_range_min=${11}
    local cct_range_max=${12}
    local awb_shift_r=${13}
    local awb_shift_g=${14}
    local awb_shift_b=${15}
    local awb_gain_r=${16}
    local awb_gain_g=${17}
    local awb_gain_b=${18}
    local nr_filter_level=${19}
    local day_night_mode=${20}
    local iris_mode=${21}
    local hue=${22}
    local brightness=${23}
    local blc_area_mode=${24}
    local contrast=${25}
    local wp_point=${26}
    local nr_mode=${27}
    
    if [ -z "${sharpness}" ]; then
        sharpness=0
    fi
    
    if [ -z "${brightness}" ]; then
        brightness=0
    fi
    
    if [ -z "${contrast}" ]; then
        contrast=0
    fi
    
    if [ -z "${hue}" ]; then
        hue=0
    fi
    
    if [ -z "${saturation}" ]; then
        saturation=0
    fi
    
    if [ -z "${iris_level}" ]; then
        iris_level=0
    fi
    
    if [ -z "${exposure_time}" ]; then
        exposure_time=0
    fi
    
    if [ -z "${saturation}" ]; then
        saturation=0
    fi
    
    if [ -z "${gain}" ]; then
        gain=0
    fi
    
    if [ -z "${ev}" ]; then
        ev=0
    fi
    
    if [ -z "${wdr_level}" ]; then
        wdr_level=0
    fi
    
    if [ -z "${cct_range_min}" ]; then
        cct_range_min=0
    fi
    
    if [ -z "${cct_range_max}" ]; then
        cct_range_max=0
    fi
    
    if [ -z "${awb_shift_r}" ]; then
        awb_shift_r=0
    fi
    
    if [ -z "${awb_shift_g}" ]; then
        awb_shift_g=0
    fi
    
    if [ -z "${awb_shift_b}" ]; then
        awb_shift_b=0
    fi
    
    if [ -z "${awb_gain_r}" ]; then
        awb_gain_r=0
    fi
    
    if [ -z "${awb_gain_g}" ]; then
        awb_gain_g=0
    fi
    
    if [ -z "${awb_gain_b}" ]; then
        awb_gain_b=0
    fi
    
    if [ -z "${nr_filter_level}" ]; then
        nr_filter_level=0
    fi
    
    if [ -z "${day_night_mode}" ]; then
        day_night_mode=auto
    fi
    
    if [ -z "${iris_mode}" ]; then
        iris_mode=manual
    fi
    
    if [ -z "${ae_mode}" ]; then
        ae_mode=auto
    fi
    
    if [ -z "${scene_mode}" ]; then
        scene_mode=auto
    fi
    
    if [ -z "${blc_area_mode}" ]; then
        blc_area_mode=off
    fi
    
    if [ -z "${awb_mode}" ]; then
        awb_mode=auto
    fi
    
    if [ -z "${wp_point}" ]; then
        wp_point="width=1920, height=1080"
    fi
    
    if [ -z "${nr_mode}" ]; then
        nr_mode=auto
    fi
    
    if [ -z "${scene_mode}" ]; then
        scene_mode=auto
    fi
 
    CASE_CONFIG="${CASE_CONFIG}\n\t\t\t<manual_3a_control"
    CASE_CONFIG="${CASE_CONFIG} sharpness=\"${sharpness}\""
    CASE_CONFIG="${CASE_CONFIG} brightness=\"${brightness}\""
    CASE_CONFIG="${CASE_CONFIG} contrast=\"${contrast}\""
    CASE_CONFIG="${CASE_CONFIG} hue=\"${hue}\""
    CASE_CONFIG="${CASE_CONFIG} saturation=\"${saturation}\""
    CASE_CONFIG="${CASE_CONFIG} iris-level=\"${iris_level}\""
    CASE_CONFIG="${CASE_CONFIG} exposure-time=\"${exposure_time}\""
    CASE_CONFIG="${CASE_CONFIG} gain=\"${gain}\""
    CASE_CONFIG="${CASE_CONFIG} ev=\"${ev}\""
    CASE_CONFIG="${CASE_CONFIG} wdr-level=\"${wdr_level}\""
    CASE_CONFIG="${CASE_CONFIG} cct-range-min=\"${cct_range_min}\""
    CASE_CONFIG="${CASE_CONFIG} cct-range-max=\"${cct_range_max}\""
    CASE_CONFIG="${CASE_CONFIG} awb-shift-r=\"${awb_shift_r}\""
    CASE_CONFIG="${CASE_CONFIG} awb-shift-g=\"${awb_shift_g}\""
    CASE_CONFIG="${CASE_CONFIG} awb-shift-b=\"${awb_shift_b}\""
    CASE_CONFIG="${CASE_CONFIG} awb-gain-r=\"${awb_gain_r}\""
    CASE_CONFIG="${CASE_CONFIG} awb-gain-g=\"${awb_gain_g}\""
    CASE_CONFIG="${CASE_CONFIG} awb-gain-b=\"${awb_gain_b}\""
    CASE_CONFIG="${CASE_CONFIG} nr-filter-level=\"${nr_filter_level}\""
    CASE_CONFIG="${CASE_CONFIG} day-night-mode=\"${day_night_mode}\""  
    CASE_CONFIG="${CASE_CONFIG} iris-mode=\"${iris_mode}\""
    CASE_CONFIG="${CASE_CONFIG} ae-mode=\"${ae_mode}\""
    CASE_CONFIG="${CASE_CONFIG} scene-mode=\"${scene_mode}\""
    CASE_CONFIG="${CASE_CONFIG} blc-area-mode=\"${blc_area_mode}\""
    CASE_CONFIG="${CASE_CONFIG} awb-mode=\"${awb_mode}\""
    CASE_CONFIG="${CASE_CONFIG} wp-point=\"${wp_point}\""
    CASE_CONFIG="${CASE_CONFIG} nr-mode=\"${nr_mode}\""
    CASE_CONFIG="${CASE_CONFIG} />"
}

function feature_setting_3_full()
{
    local feature_name=${1}
    local values=${2}
    local value_type=${3}
    local value_count=${4}
    local duration_each=${5}
    local frame_count_each=${6}
    local loop_mode=${7}
    
    if [ -z "${loop_mode}" ]; then
        loop_mode=0
    fi
    
    if [ -z "${frame_count_each}" ]; then
        frame_count_each=1
    fi
    
    if [ -z "${duration_each}" ]; then
        duration_each=1000
    fi
    
    if [ -z "${value_count}" ]; then
        value_count=1
    fi
    
    CASE_CONFIG="${CASE_CONFIG}\n\t\t\t<feature"
    CASE_CONFIG="${CASE_CONFIG} feature_name=\"${feature_name}\""
    CASE_CONFIG="${CASE_CONFIG} values=\"${values}\""
    CASE_CONFIG="${CASE_CONFIG} value_type=\"${value_type}\""
    CASE_CONFIG="${CASE_CONFIG} value_count=\"${value_count}\""
    CASE_CONFIG="${CASE_CONFIG} duration_each=\"${duration_each}\""
    CASE_CONFIG="${CASE_CONFIG} frame_count_each=\"${frame_count_each}\""
    CASE_CONFIG="${CASE_CONFIG} loop_mode=\"${loop_mode}\""
    CASE_CONFIG="${CASE_CONFIG} />"
}

function analyzer_3_full()
{
    local config_path=${1}
    
    CASE_CONFIG="${CASE_CONFIG}\n\t\t\t<analyzer config_path=\"${config_path}\" />"
}

function green_corruption_analyzer_3_full()
{
    local config_path=${1}
    
    CASE_CONFIG="${CASE_CONFIG}\n\t\t\t<green_corruption config_path=\"${config_path}\" />"
}

function orientation_analyzer_3_full()
{
    local config_path=${1}
    
    CASE_CONFIG="${CASE_CONFIG}\n\t\t\t<orientation_analyzer config_path=\"${config_path}\" />"
}

function gen_basic_capture_single_cam_case()
{
    local case_name=$1
    
    local I_RESOLUTION=`echo $case_name | awk -F_ '{print $(NF-1)}'`
    local I_PIXEL_FORMAT=`echo $case_name | awk -F_ '{print $(NF)}'`
    
    local width=`echo $I_RESOLUTION | awk -Fx '{print $(1)}'`
    local height=`echo $I_RESOLUTION | awk -Fx '{print $(2)}'`
    local format=`echo ${I_PIXEL_FORMAT} | tr '[a-z]' '[A-Z]'`
    local iomode=`echo $case_name | awk -F_ '{print $(NF-2)}'`
    if [ `echo $case_name | grep -i "30fps" | wc -l` -gt 0 ];then
        framerate=30/1
    fi
    if [ `echo $case_name | grep -i "60fps" | wc -l` -gt 0 ];then
        framerate=60/1
    fi
    local scene_mode=ull
    local wdr_level=0
    if echo $case_name | grep -q "NORMAL"; then
        scene_mode=normal
    fi
    if echo $case_name | grep -q "VHDR_HIGH"; then
        scene_mode=hdr
        wdr_level=200
    elif echo $case_name | grep -q "VHDR_MEDIUM"; then
        scene_mode=hdr
        wdr_level=100
    elif echo $case_name | grep -q "VHDR_LOW"; then
        scene_mode=hdr
        wdr_level=0
    fi
    
    if echo $case_name | grep -q "ULL"; then
        scene_mode=ull
    fi
    
    if [ -z "${width}" ]; then
        width=1920
    fi
    
    if [ -z "${height}" ]; then
        height=1080
    fi
    
    if [ -z "${pixelformat}" ]; then
        format=NV12
    fi
       
    if [ "$iomode" != "MMAP" ] && [ "$iomode" != "USERPTR" ] && [ "$iomode" != "DMA" ] && [ "$iomode" != "DMAIMPORT" ]; then
        iomode="MMAP"
    fi
    
    if [ "$iomode" == "DMAIMPORT" ]; then
        iomode="DMA_IMPORT"
    fi
    
    iomode=`echo ${iomode} | tr '[A-Z]' '[a-z]'`
    
    local ANALYZER_CONFIG_PATH="/home/root/sw_val/configuration/LibContentAnalyzerConfig.xml"

    case_0_begin ${case_name}
    config_1_begin 0
    camera_2_begin 0 12000
    camera_common_settings_3_full $width $height $format $iomode 0 video -1 any none $framerate
    camera_3a_settings_3_full $scene_mode $wdr_level
    feature_setting_3_full "content_consistent" "0" "%d" "1" "100" "1" "1"
    analyzer_3_full ${ANALYZER_CONFIG_PATH}
    green_corruption_analyzer_3_full ${ANALYZER_CONFIG_PATH}
    orientation_analyzer_3_full ${ANALYZER_CONFIG_PATH}
    camera_2_end 0
    config_1_end 0
    case_0_end ${case_name}

    echo -e ${CASE_CONFIG} > "${case_name}.xml"
}

function gen_manual_3a_setting_case()
{
    local case_name=$1
      
    if [ -z "$cameraInput" ]; then
        cameraInput=imx185
    fi
    
    . /home/root/sw_val/scripts/resolution_list/resolution_list.sh $cameraInput
   
    local width=$WIDTH
    local height=$HEIGHT
    local format=`echo ${I_PIXEL_FORMAT} | tr '[a-z]' '[A-Z]'`
    local iomode=`echo $case_name | awk -F_ '{print $(NF)}'`
    local feature_type=`echo $case_name | awk -F_ '{print $(NF-1)}'`
    local scene_mode=ull
    local wdr_level=0
    local awb_mode=auto
    local ae_mode=auto
    
    if echo $case_name | grep -q "VHDR_HIGH"; then
        scene_mode=hdr
        wdr_level=200
    elif echo $case_name | grep -q "VHDR_MEDIUM"; then
        scene_mode=hdr
        wdr_level=100
    elif echo $case_name | grep -q "VHDR_LOW"; then
        scene_mode=hdr
        wdr_level=0
    fi
    
    if echo $case_name | grep -q "ULL"; then
        scene_mode=ull
    fi
    
    if [ "$feature_type" == "EXPOSURETIME" ]; then
        ae_mode=manual
        feature_name="exposure_time"
        setting_vals="30,300,3000,30000"
        setting_val_type="%d"
        setting_val_count=4
        duration_each=5000
        if [ `echo $case_name | grep -i "VHDR" | wc -l` -gt 0 ] &&  [ "${cameraInput}" = "imx185" ]; then
            setting_vals="2500,5000,10000,20000"
        fi
    elif [ "$feature_type" == "EXPOSUREGAIN" ]; then
        ae_mode=manual
        feature_name="exposure_gain"
        setting_vals="1,20,30,40,50"
        setting_val_type="%f"
        setting_val_count=5
        duration_each=5000
        if [ `echo $case_name | grep -i "VHDR" | wc -l` -gt 0 ] &&  [ "${cameraInput}" = "imx185" ]; then
            setting_vals="1,3,6,9,12"
        fi
    elif [ "$feature_type" == "WBMODE" ]; then
        feature_name="wb_mode"
        setting_vals="2000,5000,7000,9000,1,2,3,4,5,6,7"
        setting_val_type="%d"
        setting_val_count=11
        duration_each=5000
    elif [ "$feature_type" == "WBGAIN" ]; then
        feature_name="wb_manual_gain"
        setting_vals="255,4194495,8388751,11534415,16711680"
        setting_val_type="%d"
        setting_val_count=5
        duration_each=5000
    elif [ "$feature_type" == "EXPOSUREEV" ]; then
        feature_name="exposure_ev"
        setting_vals="-4, -3, -2, -1, 0, 1, 2, 3, 4"
        setting_val_type="%d"
        setting_val_count=9
        duration_each=5000
    elif [ "$feature_type" == "BRIGHTNESS" ]; then
        feature_name="brightness"
        setting_vals="-128, -96, -64, -32, 0, 32, 64, 96, 127"
        setting_val_type="%d"
        setting_val_count=9
        duration_each=5000
    elif [ "$feature_type" == "CONTRAST" ]; then
        feature_name="contrast"
        setting_vals="-128, -96, -64, -32, 0, 32, 64, 96, 127"
        setting_val_type="%d"
        setting_val_count=9
        duration_each=5000
    elif [ "$feature_type" == "HUE" ]; then
        feature_name="hue"
        setting_vals="0, -128, -96, -64, -32, 32, 64, 96, 127"
        setting_val_type="%d"
        setting_val_count=9
        duration_each=5000
    elif [ "$feature_type" == "CCTRANGE" ]; then
        awb_mode=manual
        feature_name="wb_cct_range"
        setting_vals="2000,5000,7000,9000"
        setting_val_type="%d"
        setting_val_count=4
        duration_each=5000
    elif [ "$feature_type" == "AWBSHIFT" ]; then
        feature_name="wb_shift"
        setting_vals="255,4194495,8388751,11534415,16711680"
        setting_val_type="%d"
        setting_val_count=5
        duration_each=5000
    fi
        
    if [ -z "${pixelformat}" ]; then
        format=NV12
    fi
       
    if [ "$iomode" != "MMAP" ] && [ "$iomode" != "USERPTR" ] && [ "$iomode" != "DMA" ] && [ "$iomode" != "DMAIMPORT" ]; then
        iomode="MMAP"
    fi
    
    if [ "$iomode" == "DMAIMPORT" ]; then
        iomode="DMA_IMPORT"
    fi
    
    iomode=`echo ${iomode} | tr '[A-Z]' '[a-z]'`
    
    local ANALYZER_CONFIG_PATH="/home/root/sw_val/configuration/LibContentAnalyzerConfig.xml"

    case_0_begin ${case_name}
    config_1_begin 0
    camera_2_begin 0 12000
    camera_common_settings_3_full "$width" "$height" "$format" "$iomode"
    camera_3a_settings_3_full $scene_mode $wdr_level $awb_mode $ae_mode
    if [ ! -z "$feature_name" ]; then
        feature_setting_3_full "$feature_name" "$setting_vals" "$setting_val_type" "$setting_val_count" "$duration_each" "1" "0"
    fi
    analyzer_3_full ${ANALYZER_CONFIG_PATH}
    green_corruption_analyzer_3_full ${ANALYZER_CONFIG_PATH}
    #orientation_analyzer_3_full ${ANALYZER_CONFIG_PATH}
    camera_2_end 0
    config_1_end 0
    case_0_end ${case_name}

    echo -e ${CASE_CONFIG} > "${case_name}.xml"
}

function gen_basic_capture_four_cam_case()
{
    local case_name=$1
    #CAMERA_GST_AUTO_FOUR_CAMERA_CAM0_1280x800_YUYV_CAM1_640x480_YUYV_CAM2_1280x800_UYVY_CAM3_640x480_UYVY
    
    CAM3_CONFIG=${case_name##*CAM3_}
    CAM3_LEFT=${case_name%%_CAM3_*}
    CAM2_CONFIG=${CAM3_LEFT##*CAM2_}
    CAM2_LEFT=${CAM3_LEFT%%_CAM2_*}
    CAM1_CONFIG=${CAM2_LEFT##*CAM1_}
    CAM1_LEFT=${CAM2_LEFT%%_CAM1_*}
    CAM0_CONFIG=${CAM1_LEFT##*CAM0_}
    CAM_CONFIGS=(${CAM0_CONFIG} ${CAM1_CONFIG} ${CAM2_CONFIG} ${CAM3_CONFIG})

    if [ ! -z "$IO_MODE" ]; then
        iomode = $IO_MODE
    fi

    if [ "$iomode" != "MMAP" ] && [ "$iomode" != "USERPTR" ] && [ "$iomode" != "DMA" ] && [ "$iomode" != "DMAIMPORT" ]; then
        iomode="USERPTR"
    fi
    
    if [ "$iomode" == "DMAIMPORT" ]; then
        iomode="DMA_IMPORT"
    fi
    
    iomode=`echo ${iomode} | tr '[A-Z]' '[a-z]'`
    
    local ANALYZER_CONFIG_PATH="/home/root/sw_val/configuration/LibContentAnalyzerConfig.xml"

    case_0_begin ${case_name}
    config_1_begin 0
    
    i=0
    for CAM_CONFIG in ${CAM_CONFIGS[*]}
    do
        I_RESOLUTION=`echo $CAM_CONFIG | awk -F_ '{print $(NF-1)}'`
        I_PIXEL_FORMAT=`echo $CAM_CONFIG | awk -F_ '{print $(NF)}'`
        if [ "${I_PIXEL_FORMAT}" = "YUYV" ];then
            I_PIXEL_FORMAT=YUY2
        fi
        width=`echo $I_RESOLUTION | awk -Fx '{print $(1)}'`
        height=`echo $I_RESOLUTION | awk -Fx '{print $(2)}'`
        format=`echo ${I_PIXEL_FORMAT} | tr '[a-z]' '[A-Z]'`
        camera_2_begin $i 12000
        camera_common_settings_3_full $width $height $format $iomode
        feature_setting_3_full "content_consistent" "0" "%d" "1" "100" "1" "1"
        analyzer_3_full ${ANALYZER_CONFIG_PATH}
        green_corruption_analyzer_3_full ${ANALYZER_CONFIG_PATH}
        camera_2_end $i
        
        i=$((i+1))
    done
    config_1_end 0
    case_0_end ${case_name}

    echo -e ${CASE_CONFIG} > "${case_name}.xml"
}

function gen_basic_capture_dual_cam_case()
{
    local case_name=$1
    #CAMERA_GST_AUTO_FOUR_CAMERA_CAM0_1280x800_YUYV_CAM1_640x480_YUYV_CAM2_1280x800_UYVY_CAM3_640x480_UYVY
    
    CAM1_CONFIG=${CASE_NAME_LOWER##*cam1_}
    CAM1_LEFT=${CASE_NAME_LOWER%%_cam1_*}
    CAM0_CONFIG=${CAM1_LEFT##*cam0_}
    CAM_CONFIGS=(${CAM0_CONFIG} ${CAM1_CONFIG})

    if [ ! -z "$IO_MODE" ]; then
        iomode = $IO_MODE
    fi

    if [ "$iomode" != "MMAP" ] && [ "$iomode" != "USERPTR" ] && [ "$iomode" != "DMA" ] && [ "$iomode" != "DMAIMPORT" ]; then
        iomode="USERPTR"
    fi
    
    if [ "$iomode" == "DMAIMPORT" ]; then
        iomode="DMA_IMPORT"
    fi
    
    local ANALYZER_CONFIG_PATH="/home/root/sw_val/configuration/LibContentAnalyzerConfig.xml"

    case_0_begin ${case_name}
    config_1_begin 0
    i=0
    for CAM_CONFIG in ${CAM_CONFIGS[*]}
    do
        I_RESOLUTION=`echo $CAM_CONFIG | awk -F_ '{print $(NF-1)}'`
        I_PIXEL_FORMAT=`echo $CAM_CONFIG | awk -F_ '{print $(NF)}'`
        width=`echo $I_RESOLUTION | awk -Fx '{print $(1)}'`
        height=`echo $I_RESOLUTION | awk -Fx '{print $(2)}'`
        
        I_INTERLACED="any"
        if [ "${I_PIXEL_FORMAT}" = "YUYV" ];then
            I_PIXEL_FORMAT=YUY2
        fi
        if [ `echo $CAM_CONFIG | grep -i "interlaced" | wc -l` -gt 0 ];then
            I_INTERLACED="alternate"
            I_DEINTERLACED="sw_bob"
            if [ "${I_PIXEL_FORMAT}" = "cvbs" ];then
                I_PIXEL_FORMAT=UYVY
            fi
        fi
        if [ `echo $CAM_CONFIG | grep -i "dmabuf" | wc -l` -gt 0 ];then
            iomode=DMA_IMPORT
        elif [ `echo $CAM_CONFIG | grep -i "mmap" | wc -l` -gt 0 ];then
            iomode=MMAP
        fi
        iomode=`echo ${iomode} | tr '[A-Z]' '[a-z]'`
        format=`echo ${I_PIXEL_FORMAT} | tr '[a-z]' '[A-Z]'`
        camera_2_begin $i 12000
        camera_common_settings_3_full $width $height $format $iomode 0 video -1 $I_INTERLACED $I_DEINTERLACED
        feature_setting_3_full "content_consistent" "0" "%d" "1" "100" "1" "1"
        analyzer_3_full ${ANALYZER_CONFIG_PATH}
        green_corruption_analyzer_3_full ${ANALYZER_CONFIG_PATH}
        camera_2_end $i
        i=$((i+1))
    done
    config_1_end 0
    case_0_end ${case_name}

    echo -e ${CASE_CONFIG} > "${case_name}.xml"
}

CASE_NAME_LOWER=`echo ${CASE_NAME} | tr '[A-Z]' '[a-z]'`
if echo $CASE_NAME_LOWER | grep -q "basic_capture_single_cam"; then
    #Example: case_name=CAMERA_FUNCTION_AUTO_BASIC_CAPTURE_SINGLE_CAM_USERPTR_1920x1080_NV12
    gen_basic_capture_single_cam_case ${CASE_NAME}
elif echo $CASE_NAME_LOWER | grep -q "manual_3a_setting"; then
    #Example: case_name=CAMERA_FUNCTION_AUTO_MANUAL_3A_SETTING_EXPOSURETIME_USERPTR
    gen_manual_3a_setting_case ${CASE_NAME}
elif echo $CASE_NAME_LOWER | grep -q "camera_gst_auto_four_camera"; then
    #Example: CAMERA_GST_AUTO_FOUR_CAMERA_CAM0_1280x800_YUYV_CAM1_640x480_YUYV_CAM2_1280x800_UYVY_CAM3_640x480_UYVY
    gen_basic_capture_four_cam_case ${CASE_NAME}
elif echo $CASE_NAME_LOWER | grep -q "camera_gst_auto_dual_camera"; then
    #Example: CAMERA_GST_AUTO_DUAL_CAMERA_CAM0_1280x800_YUYV_CAM1_640x480_YUYV
    gen_basic_capture_dual_cam_case ${CASE_NAME}
fi