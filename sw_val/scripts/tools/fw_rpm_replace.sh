#!/bin/bash
project_name=$1

IPU4FW=`rpm -qa | grep ipu4fw`
if [ ! -z "${IPU4FW}" ]; then
    echo "Uninstall ${IPU4FW}"
    rpm -e ${IPU4FW} --aid --nodeps
fi

if [ "$project_name" == "DSS" ]; then
    echo "Install ipu4fw DSS......"
    IPU4FWRPM=`find ${BUILD_PATH} -regextype "posix-egrep" -regex \
        ".*ipu4fw-[0-9]{1}.[0-9]{1}.[0-9]{1}-[0-9]{1,6}.[0-9]{8}_[0-9]{4}.DSS.x86_64.rpm"`
    rpm -Uvh ${IPU4FWRPM} --aid --nodeps
    if [ $? -ne 0 ]; then
        echo "Failed to install ipu4fw DSS"
        exit -1
    fi
else
    echo "Install ipu4fw......"
    IPU4FWRPM=`find ${BUILD_PATH} -regextype "posix-egrep" -regex \
        ".*ipu4fw-[0-9]{1}.[0-9]{1}.[0-9]{1}-[0-9]{1,6}.[0-9]{8}_[0-9]{4}.x86_64.rpm"`
    rpm -Uvh ${IPU4FWRPM} --aid --nodeps
    if [ $? -ne 0 ]; then
        echo "Failed to install ipu4fw"
        exit -1
    fi
fi

echo "DONE............................."
exit 0
