#!/bin/bash

FORMAT=$1
RESOLUTION=$2
INTERLACED=$3

SUPPORTED_RES=("1920x1080" "1280x720" "720x576" "640x480" "1920x540" "720x240" "720x288")
YUV422_RGB565_LINKFREQ_INDEX=("6" "2" "1" "0" "6" "1" "1")
RGB888_LINKFREQ_INDEX=("7" "5" "4" "3" "7" "4" "4")
find_link_freq_index() {
    for res in ${SUPPORTED_RES[*]}
    do
        if [ $res != $RESOLUTION ]; then
            i=$((i+1))
        else
            break
        fi
    done
    if [ "$FORMAT" = "RGB24" ] || [ "$FORMAT" = "RGB888" ]; then
        LINKFREQ_I=${RGB888_LINKFREQ_INDEX[$i]}
    else
        LINKFREQ_I=${YUV422_RGB565_LINKFREQ_INDEX[$i]}
    fi
}
if [ "$FORMAT" = "RGB565" ]; then
    SUBDEV_FMT="RGB16"
    PIXEL_FORMAT="V4L2_PIX_FMT_XRGB32"
elif [ "$FORMAT" = "RGB24" ] || [ "$FORMAT" = "RGB888" ]; then
    SUBDEV_FMT="RGB24"
    PIXEL_FORMAT="V4L2_PIX_FMT_XBGR32"
elif [ "$FORMAT" = "UYVY" ]; then
    SUBDEV_FMT="UYVY"
elif [ "$FORMAT" = "YUYV" ]; then
    SUBDEV_FMT="YUYV"
elif [ "$FORMAT" = "NV16" ]; then
    SUBDEV_FMT="YUYV"  
else
    SUBDEV_FMT="UYVY"
fi

if [ "$INTERLACED" = "true" ]; then
    FIELD="=ALTERNATE"
fi
find_link_freq_index
chmod +x /home/root/sw_val/bin/media-ctl
chmod +x /home/root/sw_val/bin/yavta
/home/root/sw_val/bin/media-ctl -r -v

/home/root/sw_val/bin/media-ctl -V "\"adv7481 pixel array 2-00e0\":0 [fmt:$SUBDEV_FMT$FIELD/1920x1080]"  -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 binner 2-00e0\":0 [fmt:$SUBDEV_FMT$FIELD/1920x1080]"  -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 binner 2-00e0\":0 [compose:(0,0)/${RESOLUTION}]"  -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 binner 2-00e0\":1 [fmt:$SUBDEV_FMT$FIELD/${RESOLUTION}]"  -v
/home/root/sw_val/bin/media-ctl -V "\"Intel IPU4 CSI-2 0\":0 [fmt:$SUBDEV_FMT$FIELD/${RESOLUTION}]" -v

__link_freq_node=$(media-ctl -e "adv7481 binner 2-00e0")
/home/root/sw_val/bin/yavta -w "0x009f0901 $LINKFREQ_I" $__link_freq_node
/home/root/sw_val/bin/yavta -w "0x00981982 1" $(media-ctl -e "Intel IPU4 CSI-2 0")

/home/root/sw_val/bin/media-ctl -t '"Intel IPU4 CSI2 BE SOC":0(0) => 8(0)[5]'
/home/root/sw_val/bin/media-ctl -V "\"Intel IPU4 CSI2 BE SOC\":0 [fmt:$SUBDEV_FMT$FIELD/${RESOLUTION}]"  -v
/home/root/sw_val/bin/media-ctl -V "\"Intel IPU4 CSI2 BE SOC\":8 [fmt:$SUBDEV_FMT$FIELD/${RESOLUTION}]"  -v

/home/root/sw_val/bin/media-ctl -l "\"adv7481 pixel array 2-00e0\":0 -> \"adv7481 binner 2-00e0\":0[1]"  -v
/home/root/sw_val/bin/media-ctl -l "\"adv7481 binner 2-00e0\":1 -> \"Intel IPU4 CSI-2 0\":0[1]"  -v
/home/root/sw_val/bin/media-ctl -l "\"Intel IPU4 CSI-2 0\":1 -> \"Intel IPU4 CSI2 BE SOC\":0[5]"  -v
/home/root/sw_val/bin/media-ctl -l "\"Intel IPU4 CSI2 BE SOC\":8 -> \"Intel IPU4 BE SOC capture 0\":0[5]"  -v

DEV_NAME=`/home/root/sw_val/bin/media-ctl -e "Intel IPU4 BE SOC capture 0"`

. /home/root/sw_val/scripts/tools/mondello_control.sh
