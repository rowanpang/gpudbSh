#!/bin/bash

pidfile="pid-bg.log"
if [ -s $pidfile ];then
    pids=`cat $pidfile`
    echo "----kill pids: $pids-----"
    kill $pids
    rm -rf $pidfile
    exit
fi

if [ $# -lt 1 ];then
    echo "--need identifier!!---"
    exit
fi

pids=""
if [ $1 == '-ui' ];then
    #upper identify
    dirName=$2
fi

if [ -z $dirName ];then
    nodeName="$HOSTNAME"
    identify=$1
    dirName=$nodeName-$identify
fi

echo "-----log dir:$dirName------"
if [ -d $dirName ];then
    rm -rf $dirName
fi
mkdir $dirName

yum install sysstat dstat

#disk
iostat sdb sdc sdd sde sdf sdg sdh 1 -m > $dirName/disk.log &
pids="$!"

#cpu
sar -u 1 > $dirName/cpu.log	&
pids="$pids $!"

sar -P ALL 1 > $dirName/cpuPer.log 	&
pids="$pids $!"

#mem
free -c 3600 -s 1 -h > $dirName/mem.log &
pids="$pids $!"

#pidstat
pidstat -l -t -d -u -C "postgres" 1 > $dirName/pidstat.log &
pids="$pids $!"

#dstat
dstat --nocolor > $dirName/dstat.log &
pids="$pids $!"

#nvidia-pmon
nvidia-smi pmon > $dirName/nvidia-pmon.log	&
pids="$pids $!"

#nvidia-dmon
nvidia-smi dmon > $dirName/nvidia-dmon.log	&
pids="$pids $!"

echo $pids > $pidfile
echo "-----bg pids:$pids----------------"
