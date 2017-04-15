#!/bin/bash

FORMAT=$1
RESOLUTION=$2
INTERLACED=$3

if [ "$FORMAT" = "RGB565" ]; then
	SUBDEV_FMT="RGB16"
elif [ "$FORMAT" = "RGB24" ]; then
	SUBDEV_FMT="RGB24"
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

chmod +x /home/root/sw_val/bin/media-ctl
/home/root/sw_val/bin/media-ctl -r -v

/home/root/sw_val/bin/media-ctl -V "\"Intel IPU4 CSI-2 0\":0 [fmt:$SUBDEV_FMT$FIELD/${RESOLUTION}]"  -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 pixel array 2-00e0\":0 [fmt:$SUBDEV_FMT$FIELD/1920x1080]" -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 binner 2-00e0\":0 [fmt:$SUBDEV_FMT$FIELD/1920x1080]" -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 binner 2-00e0\":0 [compose:(0,0)/${RESOLUTION}]" -v
/home/root/sw_val/bin/media-ctl -V "\"adv7481 binner 2-00e0\":1 [fmt:$SUBDEV_FMT$FIELD/${RESOLUTION}]" -v

/home/root/sw_val/bin/media-ctl -l "\"adv7481 pixel array 2-00e0\":0 -> \"adv7481 binner 2-00e0\":0[1]" -v
/home/root/sw_val/bin/media-ctl -l "\"adv7481 binner 2-00e0\":1 -> \"Intel IPU4 CSI-2 0\":0[1]" -v
/home/root/sw_val/bin/media-ctl -l "\"Intel IPU4 CSI-2 0\":1 -> \"Intel IPU4 CSI-2 0 capture 0\":0[1]" -v

DEV_NAME=`/home/root/sw_val/bin/media-ctl -e "Intel IPU4 CSI-2 0 capture 0"`

. /home/root/sw_val/scripts/tools/mondello_control.sh
#yavta --data-prefix -B capture-mplane -u -c3 -n5 -I -s${RESOLUTION} -F -f BGR24 /dev/video0

