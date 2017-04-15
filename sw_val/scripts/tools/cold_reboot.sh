#!/bin/bash

if (($#<2)); then
    echo "usage:$0 host port";
    exit 1;
fi

exec 6<>/dev/tcp/$1/$2 2>/dev/null;

if (($?!=0)); then
    echo "open $1 $2 error!";
    exit 1;
fi

IP_ADDR=`LC_ALL=C ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
HOST_NAME=`hostname`

#echo $IP_ADDR >&6
#ret_code=`cat<&6`
#echo "Return $ret_code"

echo $HOST_NAME >&6
ret_code1=`cat<&6`
echo "Return $ret_code1"

exec 6<&-;
exec 6>&-; 

exit 0