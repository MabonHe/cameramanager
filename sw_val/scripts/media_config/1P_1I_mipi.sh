#!/bin/bash

declare -a FORMATS=("${!1}")
declare -a WIDTHS=("${!2}")
declare -a HEIGHTS=("${!3}")
declare -a IS_INTERLACEDS=("${!4}")
declare -a RESOLUTIONS
declare -a FIELDS

echo "FORMATS: ${FORMATS[*]}"
echo "WIDTHS: ${WIDTHS[*]}"

echo "HEIGHTS: ${HEIGHTS[*]}"
echo "IS_INTERLACEDS: ${IS_INTERLACEDS[*]}"

SUPPORTED_RES=("1920x1080" "1280x720" "720x576" "640x480" "1920x540" "720x240" "720x288")
YUV422_RGB565_LINKFREQ_INDEX=("6" "2" "1" "0" "6" "1" "1")
RGB888_LINKFREQ_INDEX=("7" "5" "4" "3" "7" "4" "4")
    
fmt_convert() {
    i=0
    for fmt in ${FORMATS[*]}
    do
        if [ $fmt = "YUV422" ]; then
            FORMATS[$i]="UYVY"
        fi
        if [ $fmt = "RGB565" ]; then
            FORMATS[$i]="RGB16"
        fi
        if [ $fmt = "RGB888" ]; then
            FORMATS[$i]="RGB24"
        fi
        if [ $fmt = "SGRBG10" ]; then
            FORMATS[$i]="SGRBG10"
        fi
        if [ $fmt = "SBGGR10" ]; then
            FORMATS[$i]="SBGGR10"
        fi
        if [ $fmt = "SRGGB10" ]; then
            FORMATS[$i]="SRGGB10"
        fi
        if [ $fmt = "SGBRG10" ]; then
            FORMATS[$i]="SGBRG10"
        fi
        if [ $fmt = "SGRBG12" ]; then
            FORMATS[$i]="SGRBG12"
        fi
        if [ $fmt = "SBGGR12" ]; then
            FORMATS[$i]="SBGGR12"
        fi
        if [ $fmt = "SRGGB12" ]; then
            FORMATS[$i]="SRGGB12"
        fi
        if [ $fmt = "SGBRG12" ]; then
            FORMATS[$i]="SGBRG12"
        fi
        echo  "FORMATS[$i]=${FORMATS[$i]}"
        i=$((i+1))
    done
}

res_combine() {
    local i=0
    for width in ${WIDTHS[*]}
    do
        RESOLUTIONS[$i]=${WIDTHS[$i]}x${HEIGHTS[$i]}
        echo  "RESOLUTIONS[$i]=${RESOLUTIONS[$i]}"
        i=$((i+1))
    done
}


find_link_freq_index() {
    local i=0
    local j=0
    for res in ${SUPPORTED_RES[*]}
    do
    if [ $res != ${RESOLUTIONS[0]} ]; then
        i=$((i+1))
    else
        break
    fi
    done
    for res in ${SUPPORTED_RES[*]}
    do
    if [ $res != ${RESOLUTIONS[1]} ]; then
        j=$((j+1))
    else
        break
    fi
    done
    echo "i=$i, j=$j"
    if [ ${FORMATS[0]} = "YUYV" ] || [ ${FORMATS[0]} = "RGB565" ] ||[ ${FORMATS[0]} = "UYVY" ] ; then
        LINKFREQ_I_0=${YUV422_RGB565_LINKFREQ_INDEX[$i]}
    else
        LINKFREQ_I_0=${RGB888_LINKFREQ_INDEX[$i]}
    fi
    if [ ${FORMATS[1]} = "YUYV" ] || [ ${FORMATS[1]} = "RGB565" ] ||[ ${FORMATS[1]} = "UYVY" ] ; then
        LINKFREQ_I_1=${YUV422_RGB565_LINKFREQ_INDEX[$j]}
    else
        LINKFREQ_I_1=${RGB888_LINKFREQ_INDEX[$j]}
    fi
    echo "LINKFREQ_I_0=${LINKFREQ_I_0} LINKFREQ_I_1=${LINKFREQ_I_1}"
}
get_fields(){
    local i=0
    for interlace in ${IS_INTERLACEDS[*]}
    do
        if [ $interlace = true ];then
            FIELDS[$i]="=ALTERNATE"
        else
            FIELDS[$i]=
        fi
        echo "FIELDS $i is ${FIELDS[$i]}"
        i=$((i+1))
    done
}
main() {
    res_combine
    find_link_freq_index
    fmt_convert
    get_fields
    chmod +x /home/root/sw_val/bin/media-ctl
    chmod +x /home/root/sw_val/bin/yavta
    /home/root/sw_val/bin/media-ctl -r -v

    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 pixel array 2-00e0\":0 [fmt:${FORMATS[0]}${FIELDS[0]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 binner 2-00e0\":0 [fmt:${FORMATS[0]}${FIELDS[0]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 binner 2-00e0\":0 [compose:(0,0)/${RESOLUTIONS[0]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 binner 2-00e0\":1 [fmt:${FORMATS[0]}${FIELDS[0]}/${RESOLUTIONS[0]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 0\":0 [fmt:${FORMATS[0]}${FIELDS[0]}/${RESOLUTIONS[0]}]"
    __link_freq_node_0=$(media-ctl -e "adv7481 binner 2-00e0")
    /home/root/sw_val/bin/yavta -w "0x009f0901 $LINKFREQ_I_0" $__link_freq_node_0
    /home/root/sw_val/bin/yavta -w "0x00981982 0" $(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0")
    /home/root/sw_val/bin/media-ctl -l '"adv7481 pixel array 2-00e0":0 -> "adv7481 binner 2-00e0":0[1]'
    /home/root/sw_val/bin/media-ctl -l "\"adv7481 binner 2-00e0\":1 -> \"Intel IPU4 CSI-2 0\":0[1]"
    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 0":1 -> "Intel IPU4 CSI-2 0 capture 0":0[1]'

    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b pixel array 2-00e2\":0 [fmt:${FORMATS[1]}${FIELDS[1]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b binner 2-00e2\":0 [fmt:${FORMATS[0]}${FIELDS[1]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b binner 2-00e2\":0 [compose:(0,0)/${RESOLUTIONS[1]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b binner 2-00e2\":1 [fmt:${FORMATS[1]}${FIELDS[1]}/${RESOLUTIONS[1]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 4\":0 [fmt:${FORMATS[1]}${FIELDS[1]}/${RESOLUTIONS[1]}]"
    __link_freq_node_1=$(/home/root/sw_val/bin/media-ctl -e "adv7481b binner 2-00e0")
    /home/root/sw_val/bin/yavta -w "0x009f0901 $LINKFREQ_I_1" $__link_freq_node_1
    /home/root/sw_val/bin/yavta -w "0x00981982 0" $(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 4")
    /home/root/sw_val/bin/media-ctl -l '"adv7481b pixel array 2-00e2":0 -> "adv7481b binner 2-00e2":0[1]'
    /home/root/sw_val/bin/media-ctl -l '"adv7481b binner 2-00e2":1 -> "Intel IPU4 CSI-2 4":0[1]'
    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 4":1 -> "Intel IPU4 CSI-2 4 capture 0":0[1]'

    DEV_NAME_1=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 0")
    DEV_NAME_2=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 4 capture 0")
    DEV_NAME=(${DEV_NAME_1} ${DEV_NAME_2})
}

main

. ${SW_VAL_ROOT}/scripts/tools/multi_mondello_control.sh 2