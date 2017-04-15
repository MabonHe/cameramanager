#!/bin/bash

declare -a FORMATS=("${!1}")
declare -a WIDTHS=("${!2}")
declare -a HEIGHTS=("${!3}")
declare -a IS_INTERLACEDS=("${!4}")
declare -a RESOLUTIONS

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

main() {
    fmt_convert
    res_combine
    chmod +x /home/root/sw_val/bin/media-ctl
    /home/root/sw_val/bin/media-ctl -r -v

    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 pixel array 2-00e0\":0/0 [fmt:${FORMATS[0]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 binner 2-00e0\":0 [fmt:${FORMATS[0]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 binner 2-00e0\":0 [compose:(0,0)/${RESOLUTIONS[0]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481 binner 2-00e0\":1 [fmt:${FORMATS[0]}/${RESOLUTIONS[0]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 0\":0/0 [fmt:${FORMATS[0]}/${RESOLUTIONS[0]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 0\":1/0 [fmt:${FORMATS[0]}/${RESOLUTIONS[0]}]"

    /home/root/sw_val/bin/media-ctl -l "\"adv7481 binner 2-00e0\":1 -> \"Intel IPU4 CSI-2 0\":0[1]"
    /home/root/sw_val/bin/media-ctl -t '"Intel IPU4 CSI-2 0":0 => 1[0]'
    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 0":1 -> "Intel IPU4 CSI-2 0 capture 0":0[1]'

    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b pixel array 2-00e2\":0/0 [fmt:${FORMATS[1]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b binner 2-00e2\":0 [fmt:${FORMATS[0]}/1920x1080]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b binner 2-00e2\":0 [compose:(0,0)/${RESOLUTIONS[1]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"adv7481b binner 2-00e2\":1 [fmt:${FORMATS[1]}/${RESOLUTIONS[1]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 4\":0/0 [fmt:${FORMATS[1]}/${RESOLUTIONS[1]}]"
    /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 4\":1/0 [fmt:${FORMATS[1]}/${RESOLUTIONS[1]}]"

    /home/root/sw_val/bin/media-ctl -l '"adv7481b binner 2-00e2":1 -> "Intel IPU4 CSI-2 4":0[1]'
    #/home/root/sw_val/bin/media-ctl -t '"Intel IPU4 CSI-2 4":0 => 1[0]'
    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 4":1 -> "Intel IPU4 CSI-2 4 capture 0":0[1]'

    DEV_NAME_1=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 0")
    DEV_NAME_2=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 4 capture 0")
    DEV_NAME=(${DEV_NAME_1} ${DEV_NAME_2})
}

main
. ${SW_VAL_ROOT}/scripts/tools/multi_mondello_control.sh 2
