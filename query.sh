#!/bin/bash

function usage() {
    echo "usage: $0 [option]
	-m: force mon
	-t: tbName  [$tbName]
	-d: dbName  [$dbName]
	-q: spcify qX	[all]
	"
    exit 0
}

function optParser() {
    while getopts ":hd:t:q:m" opt;do
	case $opt in
	    h)
		usage
		;;
	    d)
		dbName="$OPTARG"
		;;
	    t)
		tbName="$OPTARG"
	        ;;
	    q)
		idx="$OPTARG"
		start=$idx
		end=$idx
		defaultMon="false"
	        ;;
	    m)
		forceMon="true"
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
}

function doQuery() {
    start=$1
    end=$2

    for idx in `seq $start $end`;do
	query=./sql/q$idx.sql
	bSuffix=`basename $query`
	baseName=${bSuffix%%.*}
	echo "`date +%Y%m%d-%H:%M:%S`,do query: $query"
	qOutSub="${qOutRoot}/${baseName}"
	if [ -d $qOutSub ];then
	    rm -rf $qOutSub
	fi
	mkdir -p $qOutSub

	cp -f monitor.sh $qOutRoot

	#start monitor
	if [ $forceMon == "true" -o  $defaultMon == "true" ];then
	    cd $qOutRoot && ./monitor.sh "$baseName-mon"
	    cd - >/dev/null 2>&1
	fi

	sql="select count(trip_id) from trips where trip_id < 5;
	    `cat $query`
	    "
	sql=`echo "$sql" | sed "s/from trips\|FROM trips/FROM $tbName/"`
	#echo "$sql"
	for i in {1..8};do
	    resultFile="$qOutSub/$i.txt"
	    resultFileS="$qOutSub/$i.txt.sort"
	    escape=`echo "$sql" | $MEGAWISE_HOME/bin/psql -h /tmp -f - -o $resultFile $dbName 2>/dev/null | awk '/Time: / {print $2}'`
	    sort $resultFile -o $resultFileS
	    #echo "$i,spend $escape ms"
	    echo "$escape"
	done

	#stop monitor
	if [ $forceMon == "true" -o $defaultMon == "true" ];then
	    cd $qOutRoot && ./monitor.sh
	    cd - >/dev/null 2>&1
	fi

	echo
    done
}

qOutRoot="./qOut"
dbName="postgres"
tbName="trips"
start="0"
end="4"

defaultMon="true"
forceMon="false"

function doInit() {
    tsufix=`date +%Y%m%d-%H%M%S`
    qOutRoot="$qOutRoot.q$start..$end.$tsufix"
    if [ -d "${qOutRoot}" ]; then
	mv $qOutRoot $qOutRoot.$tsufix
	echo "backup to $qOutRoot.$tsufix"
    fi

    mkdir -p ${qOutRoot}
}

function main() {
    optParser $@
    doInit
    doQuery $start $end
}

main $@
