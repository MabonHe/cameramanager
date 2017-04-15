#!/bin/bash

SW_VAL_ROOT=/home/root/sw_val
BUILD_PATH=${SW_VAL_ROOT}/build
ARTIFACTS_SERVER_IP=10.239.134.238

cp -r ${SW_VAL_ROOT}/scripts/tools/.ssh ~
chmod 600 ~/.ssh/id_rsa

function copy_build()
{
    local build_type=$1
    local build_number=$2
    local copy_method=$3
    local ARTIFACTS_PATH=""
    local ARTIFACTS_USER_LIB_FILENAME=libraries-${build_number}.tar.bz2
    local ARTIFACTS_BZIMAGE_FILENAME=bzimage-${build_number}.tar.bz2
    local IP_ADDR=`LC_ALL=C ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
    
    if [ -z "$build_number" ]; then
        echo "Plase assign build nubmer!"
        return -1
    fi
    
    if [ ! -d  ${BUILD_PATH} ]; then
        mkdir $BUILD_PATH
    fi

    cd $BUILD_PATH
    rm -rf $BUILD_PATH/*
        
    if [ "$copy_method" == "staf" ]; then
        if [ "$build_type" == "DailyBuild" ]; then
            ARTIFACTS_PATH=/share/nfs/Artifacts/DailyBuild/${build_number}
            staf $ARTIFACTS_SERVER_IP fs copy FILE $ARTIFACTS_PATH/$ARTIFACTS_USER_LIB_FILENAME TODIRECTORY $BUILD_PATH TOMACHINE $IP_ADDR
            staf $ARTIFACTS_SERVER_IP fs copy FILE $ARTIFACTS_PATH/$ARTIFACTS_BZIMAGE_FILENAME TODIRECTORY $BUILD_PATH TOMACHINE $IP_ADDR
        elif [ "$build_type" == "CIBuild" ]; then
            ARTIFACTS_PATH=/share/nfs/Artifacts/CIBuild/${build_number}
            staf $ARTIFACTS_SERVER_IP fs copy DIRECTORY $ARTIFACTS_PATH TODIRECTORY $BUILD_PATH TOMACHINE $IP_ADDR RECURSE
        else
            echo "Unknown build type ${build_type}"
            return -1
        fi
    else
        if [ "$build_type" == "DailyBuild" ]; then
            if [ "$build_number" == "latest" ]; then
                build_number=`ssh root@${ARTIFACTS_SERVER_IP} cat /share/nfs/Artifacts/DailyBuild/copiedbuilds.txt | tail -n1`
            fi
            ARTIFACTS_PATH=root@${ARTIFACTS_SERVER_IP}:/share/nfs/Artifacts/DailyBuild/${build_number}
        elif [ "$build_type" == "CIBuild" ]; then
            ARTIFACTS_PATH=root@${ARTIFACTS_SERVER_IP}:/share/nfs/Artifacts/CIBuild/${build_number}
        else
            echo "Unknown build type ${build_type}"
            return -1
        fi

        echo "Copy user space libs ${ARTIFACTS_USER_LIB_FILENAME}......"
        scp ${ARTIFACTS_PATH}/${ARTIFACTS_USER_LIB_FILENAME} $BUILD_PATH
        
        echo "Copy new kernel image ${ARTIFACTS_BZIMAGE_FILENAME}......"
        scp ${ARTIFACTS_PATH}/${ARTIFACTS_BZIMAGE_FILENAME} $BUILD_PATH
        
        echo "Copy txt files......"
        scp ${ARTIFACTS_PATH}/*.txt $BUILD_PATH
    fi

    if [ ! -f  ${BUILD_PATH}/${ARTIFACTS_USER_LIB_FILENAME} ]; then
        echo "Failed to copy user space lib ${ARTIFACTS_USER_LIB_FILENAME} from artifactory"
        return 1
    fi

    tar xjvf ${BUILD_PATH}/${ARTIFACTS_USER_LIB_FILENAME}
    if [ $? -ne 0 ]; then
        echo "Failed to unzip the user lib tarball"
        return -1
    fi    

    if [ ! -f  ${BUILD_PATH}/${ARTIFACTS_BZIMAGE_FILENAME} ]; then
        echo "Failed to copy bzimage ${ARTIFACTS_BZIMAGE_FILENAME} from artifactory"
        return 1
    fi

    tar xjvf ${BUILD_PATH}/${ARTIFACTS_BZIMAGE_FILENAME}
    if [ $? -ne 0 ]; then
        echo "Failed to unzip the kernel tarball"
        return -1
    fi

    echo "Unzip kernel modules"
    mkdir modules
    tar xzvf modules-intel-corei7-64.tgz -C modules/
    sleep 5

    echo "Change the owner of bzimage"
    chown root:root bzImage-intel-corei7-64.bin

    echo "change the owner of modules"
    chown -R root:root modules/*
    
    return 0
}

function install_bz_image()
{
    local EMMC_OR_USB=$1
    
    cd ${BUILD_PATH}
    
    echo "Check the module version"
    cur_moduleversion=`ls /lib/modules/`
    new_moduleversion=`ls ${BUILD_PATH}/modules/lib/modules/`
    
    echo "the current kernel module version is ${cur_moduleversion}"
    echo "the new kernel module version is ${new_moduleversion}"

    if [ "${cur_moduleversion}" == "${new_moduleversion}" ]; then
        echo "Kernel module version is same"
    else
        mv /lib/modules/${cur_moduleversion} /lib/modules/${new_moduleversion}
        echo "Change kernel module version to ${new_moduleversion}"
    fi

    umount /mnt
    if [ "$EMMC_OR_USB" == "USB" ]; then
        echo "mount /dev/sda1 /mnt"
        mount /dev/sda1 /mnt
    else
        echo "mount /dev/mmcblk0p1 /mnt"
        mount /dev/mmcblk0p1 /mnt
    fi

    echo "cp bzImage-intel-corei7-64.bin /mnt/vmlinuz"
    cp bzImage-intel-corei7-64.bin /mnt/vmlinuz
    umount /mnt

    echo "cp -rf modules/* /"
    cp -rf modules/* /

    echo "install ok!"
    return 0
}

function install_user_libs()
{   
    local project_name=$1
    cd ${BUILD_PATH}
    
    #To solve issue: "cannot open Packages database in /var/lib/rpm"
    rm /var/lib/rpm/__db.*
    
    echo "Remove old rpms......"
    local ICAMAMERSRC=`rpm -qa | grep icamerasrc`
    local LIBCAMHAL=`rpm -qa | grep libcamhal`
    local IPU4FW=`rpm -qa | grep ipu4fw`
    local LIBIACSS=`rpm -qa | grep libiacss`
    local LIBIAAIQ=`rpm -qa | grep libiaaiq`
    local AIQB=`rpm -qa | grep aiqb`

    if [ ! -z "${ICAMAMERSRC}" ]; then
        echo "Uninstall ${ICAMAMERSRC}"
        rpm -e ${ICAMAMERSRC} --aid --nodeps
    fi
    if [ ! -z "${LIBCAMHAL}" ]; then
        echo "Uninstall ${LIBCAMHAL}"
        rpm -e ${LIBCAMHAL} --aid --nodeps
    fi
    if [ ! -z "${IPU4FW}" ]; then
        echo "Uninstall ${IPU4FW}"
        rpm -e ${IPU4FW} --aid --nodeps
    fi
    if [ ! -z "${LIBIACSS}" ]; then
        echo "Uninstall ${LIBIACSS}"
        rpm -e ${LIBIACSS} --aid --nodeps
    fi
    if [ ! -z "${LIBIAAIQ}" ]; then
        echo "Uninstall ${LIBIAAIQ}"
        rpm -e ${LIBIAAIQ} --aid --nodeps
    fi
    if [ ! -z "${AIQB}" ]; then
        echo "Uninstall ${AIQB}"
        rpm -e ${AIQB} --aid --nodeps
    fi
       
    echo "Install aiqb......"
    if [ -f ${BUILD_PATH}/aiqb*.rpm ]; then
        rpm -Uvh ${BUILD_PATH}/aiqb*.rpm --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install aiqb"
            return -1
        fi
    else
        echo "Failed to install aiqb due to rpm not exist"
        return -1
    fi
    
    echo "Install libiaaiq......"
    if [ -f ${BUILD_PATH}/libiaaiq*.rpm ]; then
        rpm -Uvh ${BUILD_PATH}/libiaaiq*.rpm --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install libiaaiq"
            return -1
        fi
    else
        echo "Failed to install libiaaiq due to rpm not exist"
        return -1
    fi
    
    echo "Install libiacss......"
    if [ -f ${BUILD_PATH}/libiacss*.rpm ]; then
        rpm -Uvh ${BUILD_PATH}/libiacss*.rpm --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install libiacss"
            return -1
        fi
    else
        echo "Failed to install libiacss due to rpm not exist"
        return -1
    fi
    
    if [ "$project_name" == "DSS" ]; then
        echo "Install ipu4fw DSS......"
        IPU4FWRPM=`find ${BUILD_PATH} -regextype "posix-egrep" -regex \
            ".*ipu4fw-[0-9]{1}.[0-9]{1}.[0-9]{1}-[0-9]{1,6}.*.DSS.x86_64.rpm"`
        if [ -z "$IPU4FWRPM" ]; then
            echo "Failed to install ipu4fw DSS due to rpm not exist"
            return -1
        fi
        rpm -Uvh ${IPU4FWRPM} --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install ipu4fw DSS"
            return -1
        fi
    elif [ "$project_name" == "TSD" ]; then
        echo "Install ipu4fw TSD......"
        IPU4FWRPM=`find ${BUILD_PATH} -regextype "posix-egrep" -regex \
            ".*ipu4fw-[0-9]{1}.[0-9]{1}.[0-9]{1}-[0-9]{1,6}.*.TSD.x86_64.rpm"`
        if [ -z "$IPU4FWRPM" ]; then
            echo "Failed to install ipu4fw TSD due to rpm not exist"
            return -1
        fi
        rpm -Uvh ${IPU4FWRPM} --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install ipu4fw TSD"
            return -1
        fi
    else
        echo "Install ipu4fw......"
        IPU4FWRPM=`find ${BUILD_PATH} -regextype "posix-egrep" -regex \
            ".*ipu4fw-[0-9]{1}.[0-9]{1}.[0-9]{1}-[0-9]{1,6}.[0-9]{0,8}.[0-9]{0,4}.x86_64.rpm"`
        if [ -z "$IPU4FWRPM" ]; then
            echo "Failed to install ipu4fw due to rpm not exist"
            return -1
        fi
        rpm -Uvh ${IPU4FWRPM} --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install ipu4fw"
            return -1
        fi
    fi
    
    echo "Install libcamhal......"
    if [ -f ${BUILD_PATH}/libcamhal*.rpm ]; then
        rpm -Uvh ${BUILD_PATH}/libcamhal*.rpm --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install libcamhal"
            return -1
        fi
    else
        echo "Failed to install libcamhal due to rpm not exist"
        return -1
    fi
    
    echo "Install icamerasrc......"
    if [ -f ${BUILD_PATH}/icamerasrc*.rpm ]; then
        rpm -Uvh ${BUILD_PATH}/icamerasrc*.rpm --aid --nodeps
        if [ $? -ne 0 ]; then
            echo "Failed to install icamerasrc"
            return -1
        fi
    else
        echo "Failed to install icamerasrc due to rpm not exist"
        return -1
    fi
    echo "install ok!"

    return 0
}