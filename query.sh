#!/bin/bash

queryWK="$PG_HOME/script/qOut"
if ! [  -d "${queryWK}" ]; then
	mkdir -p ${queryWK}
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

for query in $PG_HOME/script/sql/q{0,1,2,3,4}.sql;do
	bSuffix=`basename $query`
	baseName=${bSuffix%%.*}
	echo "`date +%Y%m%d-%H:%M:%S`,do query:$baseName"
	outDir="${queryWK}/${baseName}"
	if [ -d $outDir ];then
		rm -rf $outDir
	fi
	mkdir -p $outDir

        sql="select count(trip_id) from trips where trip_id < 5;
`cat $query`
"
	#sql=`echo "$sql" | sed "s/from trips\|FROM trips/FROM $tbName/"`	
	#echo "$sql"
        for i in {1..8};do
                resultFile="$outDir/$i.txt"
                resultFileS="$outDir/$i.txt.sort"
                escape=`echo "$sql" | $PG_HOME/bin/psql -h /tmp -f - -o $resultFile $dbName 2>/dev/null | awk '/Time: / {print $2}'`
                sort $resultFile -o $resultFileS
                #echo "$i,spend $escape ms"
                echo "$escape"
        done

        echo
done
