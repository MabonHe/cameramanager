#!/bin/bash


declare -a FORMATS=("${!1}")
declare -a WIDTHS=("${!2}")
declare -a HEIGHTS=("${!3}")
declare -a IS_INTERLACEDS=("${!4}")
declare -a RESOLUTIONS

STREAM_NR=4
I2C_ADAPTER=0

fmt_convert() {
    i=0
    for fmt in ${FORMATS[*]}
    do
        if [ $fmt = "YUV422" ]; then
            FORMATS[$i]="YUYV"
        fi
        if [ $fmt = "RGB565" ]; then
            FORMATS[$i]="RGB16"
            PIXEL_FORMAT[$i]="V4L2_PIX_FMT_XRGB32"
        fi
        if [ $fmt = "RGB24" ]; then
            FORMATS[$i]="RGB24"
            PIXEL_FORMAT[$i]="V4L2_PIX_FMT_XBGR32"
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

    /home/root/sw_val/bin/media-ctl -v -t "\"TI964 0-003d\":0(0) => 4(0)[5]"
    /home/root/sw_val/bin/media-ctl -v -t "\"TI964 0-003d\":1(0) => 4(1)[5]"
    /home/root/sw_val/bin/media-ctl -v -t "\"TI964 0-003d\":2(0) => 4(2)[5]"
    /home/root/sw_val/bin/media-ctl -v -t "\"TI964 0-003d\":3(0) => 4(3)[5]"
    
    /home/root/sw_val/bin/media-ctl -v -t "\"Intel IPU4 CSI-2 0\":0(0) => 1(0)[3]"
    /home/root/sw_val/bin/media-ctl -v -t "\"Intel IPU4 CSI-2 0\":0(1) => 2(1)[1]"
    /home/root/sw_val/bin/media-ctl -v -t "\"Intel IPU4 CSI-2 0\":0(2) => 3(2)[1]"
    /home/root/sw_val/bin/media-ctl -v -t "\"Intel IPU4 CSI-2 0\":0(3) => 4(3)[1]"

    
    j=0
    while [ $j -lt $STREAM_NR ]
    do
        /home/root/sw_val/bin/media-ctl -v -V "\"TI964 0-003d\":$j/0 [fmt:${FORMATS[$j]}/${RESOLUTIONS[$j]}]"
        /home/root/sw_val/bin/media-ctl -v -V "\"TI964 0-003d\":4/$j [fmt:${FORMATS[$j]}/${RESOLUTIONS[$j]}]"
        
        /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 0\":0/$j [fmt:${FORMATS[$j]}/${RESOLUTIONS[$j]}]"
        m=`expr $j + 1`
        /home/root/sw_val/bin/media-ctl -v -V "\"Intel IPU4 CSI-2 0\":$m [fmt:${FORMATS[$j]}/${RESOLUTIONS[$j]}]"
        media-ctl -v -V "\"ov10635 pixel array $I2C_ADAPTER-006$m\":0 [fmt:${FMTS[$j]}/1280x800]"
        /home/root/sw_val/bin/media-ctl -v -V "\"ov10635 binner $I2C_ADAPTER-006$m\":0 [fmt:${FORMATS[$j]}/1280x800]"
        /home/root/sw_val/bin/media-ctl -v -V "\"ov10635 binner $I2C_ADAPTER-006$m\":0 [compose:(0,0)/${RESOLUTIONS[$j]}]"
        /home/root/sw_val/bin/media-ctl -v -V "\"ov10635 binner $I2C_ADAPTER-006$m\":1 [fmt:${FORMATS[$j]}/${RESOLUTIONS[$j]}]"
        /home/root/sw_val/bin/media-ctl -l "\"ov10635 binner $I2C_ADAPTER-006$m\":1 -> \"TI964 0-003d\":$j[1]"
        
        j=$((j+1))
    done
    
    /home/root/sw_val/bin/media-ctl -l '"TI964 0-003d":4 -> "Intel IPU4 CSI-2 0":0[1]'
    
    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 0":1 -> "Intel IPU4 CSI-2 0 capture 0":0[1]'

    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 0":2 -> "Intel IPU4 CSI-2 0 capture 1":0[1]'

    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 0":3 -> "Intel IPU4 CSI-2 0 capture 2":0[1]'

    /home/root/sw_val/bin/media-ctl -l '"Intel IPU4 CSI-2 0":4 -> "Intel IPU4 CSI-2 0 capture 3":0[1]'
    
    DEV_NAME_1=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 0")
    DEV_NAME_2=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 1")
    DEV_NAME_3=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 2")
    DEV_NAME_4=$(/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 3")
    DEV_NAME=(${DEV_NAME_1} ${DEV_NAME_2} ${DEV_NAME_3} ${DEV_NAME_4})
}

main