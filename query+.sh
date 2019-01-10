#!/bin/bash

source zdb.sh 

queryWK="$PG_HOME/script/queryRoot"
if ! [  -d "${queryWK}" ]; then
	mkdir -p ${queryWK}
fi

for query in `ls $PG_HOME/script/sql/q{1,2,3,4}+.sql`;do
	bSuffix=`basename $query`
	baseName=${bSuffix%%.*}
	echo -n "`date +%Y%m%d-%H:%M:%S`,do query for:$baseName,"
	echo "time spent in ms:"

	outDir="${queryWK}/${baseName}"
	if [ -d $outDir ];then
		rm -rf $outDir
	fi
	mkdir -p $outDir
	
	resultFile="$outDir/$i.txt"
	resultFileS="$outDir/$i.txt.sort"
	escape=`$PG_HOME/bin/psql -h /tmp -f ${query} -o $resultFile test 2>/dev/null | awk '/Time: / {print $2}'`
	sort $resultFile -o $resultFileS
	echo "$escape"
	echo
done
