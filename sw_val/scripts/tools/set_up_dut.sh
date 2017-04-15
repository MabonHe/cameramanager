#!/bin/bash
DUT_NAME=$1
if [ -z "$DUT_NAME" ]; then
    DUT_NAME=CIT_DSS_Linux_APL_001
fi

echo $DUT_NAME > /etc/hostname
echo "exec matchbox-session" > /home/root/.xinitrc
echo "export MONDELLO_SERVER_IP=10.239.134.231
#export cameraInput=mondello
#export cameraInput=tpg
export cameraInput=imx185
export XDG_RUNTIME_DIR=/tmp
. /usr/local/staf/startSTAFProc.sh
xinit > /dev/null 2>&1 &" >>/etc/profile
echo "g1:12345:wait:/bin/login root" >>/etc/inittab
