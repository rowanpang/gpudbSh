#!/bin/bash

function usage () {
    echo "Usage :  $0 [options] [identify]
        Options:
        -h		    Display this message
        -d  dirname	    log dirName
	-v  verbose level   loglevel [$verbose]
	-i  interval	    monitor interval [$interval]
	-c  count	    monitor count [$count]
    "
    exit 0
}

function cmdChkInstall(){
    cmd=$1
    pkg=$cmd
    [ $# -ge 2 ] && pkg=$2

    [ $verbose -ge 1 ] && echo "do cmdChkInstall for $cmd, pkg:$pkg"

    command -v $cmd >/dev/null 2>&1

    if ! [ $? ];then
	[ $verbose -ge 1 ] && echo "cmd $cmd not found,do yum install $pkg"
	yum --assumeyes install  $pkg
    fi
}

function optParser(){
    #init val is based on max run time  half an hour
    ((count=1800/$interval))
    while getopts ":hd:v:i:c:" opt;do
        case $opt in
            h)
                usage
                ;;
            d)
        	dirName="$OPTARG"
                ;;
	    v)
		verbose="$OPTARG"
		;;
	    i)
		interval="$OPTARG"
		#update count
		((count=(1800+$interval-1)/$interval))
		;;
	    c)
		count="$OPTARG"
		;;
	    \?)
		echo "--Invalid args -$OPTARG"
		usage
		;;
	    :)
		echo "--Need arguement -$OPTARG"
		usage
		;;
	esac
    done
    shift $(($OPTIND-1))
    identify=$1
}

function depCheck(){
    if [ $UID -ne 0 ];then
	[ $verbose -ge 1 ] && echo "not run as root, return"
	return
    fi

    [ $verbose -ge 1 ] && echo 'in func depCheck'
    cmdChkInstall dstat
    cmdChkInstall pidstat sysstat
    cmdChkInstall lshw
    cmdChkInstall lsscsi
    cmdChkInstall ip iproute
    [ $verbose -ge 1 ] && echo 'out func depCheck'
}

function doMon(){
    pids=""
    #disk
    recCmd="iostat"
    iostat -m sd{a..z} sda{a..z} $interval $count > $dirName/disk.log &
    pids="$pids $recCmd,$!"

    #disk-extra
    recCmd="iostat"
    iostat -m -x  sd{a..z} sda{a..z} $interval $count > $dirName/disk.log.extra &
    pids="$pids $recCmd,$!"

    #cpu
    recCmd="sar"
    sar -u $interval $count > $dirName/cpu.log	&
    pids="$pids $recCmd,$!"

    #mem
    recCmd="free"
    free -c $count -s $interval -h > $dirName/mem.log &
    pids="$pids $recCmd,$!"

    recCmd="pidstat"
    #pidstat
    pidstat -l -t -d -u -C "megawise_server|postgres" $interval $count > $dirName/pidstat.log &
    pids="$pids $recCmd,$!"

:<<EOF
    top:
	-d: interval
	-n: count
	-b: batch mode
	-i: skip idle process
	-c: command show
	-w: wild show	#confilict with -o
	-o: sort by
EOF
    recCmd="top"
    COLUMNS=167 top -d $interval -n $count -b -i -c -o RES > $dirName/top.log &
    pids="$pids $recCmd,$!"

    #nvidia-pmon
    recCmd="nvidia-smi"
    nvidia-smi pmon > $dirName/nvidia-pmon.log      &
    pids="$pids $recCmd,$!"

    #nvidia-dmon
    recCmd="nvidia-smi"
    nvidia-smi dmon > $dirName/nvidia-dmon.log      &
    pids="$pids $recCmd,$!"

    #nvidia-smi -lms 500
    recCmd="nvidia-smi"
    nvidia-smi -lms 500 > $dirName/nvidia-lms.log      &
    pids="$pids $recCmd,$!"


    echo $pids > $pidfile
    [ $verbose -ge 1 ] && echo "-----bg pids:$pids----------------"
}

function doInit() {
    if [ -z $dirName ];then
	if [ -z $identify ];then
	    echo "--need identifier!! exit 1---"
	    exit 1
	fi
	nodeName="$HOSTNAME"
	dirName=$nodeName-$identify
    fi

    if [ $verbose -ge 1 ];then
	echo "idt:$identify,dir:$dirName,verbose:$verbose"
	echo "-----log dir:$dirName------"
    fi

    [ -d $dirName ] && rm -rf $dirName
    mkdir $dirName
}

function checkKill() {
    if [ -s $pidfile ];then
	pidCmds=`cat $pidfile`
	[ $verbose -ge 1 ] && echo "----try kill: $pidCmds-----"

	for pidCmd in $pidCmds;do
	    pid=${pidCmd#*,}
	    oCmd=${pidCmd%,*}
	    cCmd=`ps -o pid,command $pid 2>/dev/null | awk '{if (NR>1) print $2}'`

            if [ X$cCmd != X ];then
                match=`echo $cCmd | grep -c $oCmd`
                if [ $match -ge 1 ] ;then
                    killStat="match"
                    kill $pid
		    if [ $? -eq 0 ];then
			killStat="$killStat-ok"
		    else
			killStat="$killStat-ng"
			notRM="true"
		    fi
                else
		    killStat="notMath cCmd $cCmd,skip"
		    notRM="true"
                fi
            fi

            [ $verbose -ge 1 ] && printf "\tkill pid-oCmd: %-20s---%s\n" "$pid-$oCmd" "$killStat"
        done

        [ X$notRM == X ] && rm -rf $pidfile
        exit
    fi
}

function gatherInfo(){
    pfx="info-"
    lsscsi > $dirName/${pfx}lsscsi.log
    df -h > $dirName/${pfx}df.log

    cat /etc/os-release > $dirName/${pfx}osInfo.log
    echo >> $dirName/${pfx}osInfo.log
    uname -a >> $dirName/${pfx}osInfo.log

    lshw > $dirName/${pfx}lshw.log 2>/dev/null	#for normal user warning
    lscpu > $dirName/${pfx}lscpu.log
    ip a > $dirName/${pfx}ipA.log

    nvidia-smi --list-gpus > $dirName/${pfx}gpus.log
    nvidia-smi -q -d CLOCK > $dirName/${pfx}gpus.clock.log
    nvidia-smi -q -d SUPPORTED_CLOCKS > $dirName/${pfx}gpus.clock.supported.log
}

function main(){
    optParser $@
    checkKill
    doInit
    depCheck
    gatherInfo
    doMon
    return 0
}

verbose="0"
pidfile="pid-bg.log"
interval=1
count=""

main $@
