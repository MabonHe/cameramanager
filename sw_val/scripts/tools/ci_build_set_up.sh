#!/bin/bash

build_number=$1
EMMC_OR_USB=$2
project_name=$3

if [ -z "$build_number" ]; then
    echo "Usage: ci_build_set_up.sh build_no EMMC/USB"
    exit -1
fi

. /home/root/sw_val/scripts/tools/set_up_bz_image_user_libs.sh

echo "Copy CIBuild ${build_number}"
copy_build CIBuild $build_number staf
ret=$?
if [ 0 -ne $ret ]; then
    echo "Failed to copy build ${build_number}"
    exit -1
fi

echo "Install CIBuild ${build_number} user libs"
install_user_libs $project_name
ret=$?
if [ 0 -ne $ret ]; then
    echo "Failed to install CIBuild ${build_number} user libs"
    exit -1
fi

echo "Install CIBuild ${build_number} Kernel image"
install_bz_image $EMMC_OR_USB
ret=$?
if [ 0 -ne $ret ]; then
    echo "Failed to install CIBuild ${build_number} Kernel image"
    exit -1
fi

echo "DONE............................."
exit 0
