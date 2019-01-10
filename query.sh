#!/bin/bash

qOutRoot="./qOut"
if ! [  -d "${qOutRoot}" ]; then
    mkdir -p ${qOutRoot}
fi

dbName="postgres"
tbName="trips"

while [ $# -gt 0 ]; do
    case "$1" in
        -d)
            dbName=$2
            shift
            ;;
        -t)
            tbName=$2
            shift
            ;;
     	*)
            echo "---args error----"
            echo "usage:$0 -t/-d/-n/-a"
            exit
            ;;
    esac
    shift
done

for query in ./sql/q{0,1,2,3,4}.sql;do
    bSuffix=`basename $query`
    baseName=${bSuffix%%.*}
    echo "`date +%Y%m%d-%H:%M:%S`,do query:$baseName"
    qOutSub="${qOutRoot}/${baseName}"
    if [ -d $qOutSub ];then
	rm -rf $qOutSub
    fi
    mkdir -p $qOutSub

    cp -f monitor.sh $qOutRoot

    #start monitor
    cd $qOutRoot && ./monitor.sh "$baseName-mon" && cd -

    #sql="select count(trip_id) from trips where trip_id < 5;
#`cat $query`
#"
    ##sql=`echo "$sql" | sed "s/from trips\|FROM trips/FROM $tbName/"`
    ##echo "$sql"
    #for i in {1..8};do
        #resultFile="$qOutSub/$i.txt"
        #resultFileS="$qOutSub/$i.txt.sort"
        #escape=`echo "$sql" | $PG_HOME/bin/psql -h /tmp -f - -o $resultFile $dbName 2>/dev/null | awk '/Time: / {print $2}'`
        #sort $resultFile -o $resultFileS
        ##echo "$i,spend $escape ms"
        #echo "$escape"
    #done

    #stop monitor
    cd $qOutRoot && ./monitor.sh && cd -

    echo
done
