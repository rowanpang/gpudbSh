#!/bin/bash
dbName="postgres"
tbName="trips"
cpTimes=1
doAppend=1

data_basedir=$HOME/NYC_TAXI
data_path=$data_basedir/rowan

function usage()
{
    echo "---args error----"
    echo "usage:$0 options
	    -t:tb/$tbName
	    -d:db/$dbName
	    -n:cpTimes
	    -r:reCreate not append
	    -m:multiload
	    -f:full csv"
    echo "---default is:
	append data to $tbName table in db $dbName----"
    exit
}

while [ $# -gt 0 ]; do
    case "$1" in
        -t)
	    tbName=$2
	    shift
   	    ;;
	-d)
	    dbName=$2
	    shift
	    ;;
	-n)
	    cpTimes=$2
	    shift
	    ;;
	-r)
	    doAppend=0
	    ;;
	-f)
	    data_path=$data_basedir/data
	    ;;
	-r)
	    multiload="true"
	    ;;
    	*)
	    usage
	    ;;
    esac
    shift
done

function tableOps()
{
    sqlCreateOrg=`cat ${MEGAWISE_HOME}/script/sql/create_trips_table.sql`
    if [ "$doAppend" -eq 1 ];then
	sql=`echo "$sqlCreateOrg" | sed '1d' | sed "1s/trips/IF NOT EXISTS $tbName/"`
	msg="doAppend"
    else
	sql=`echo "$sqlCreateOrg" | sed "1,2s/trips/$tbName/"`
	msg="reCreate"
    fi

    echo
    echo "$sql" | head -n 3
    echo "........"
    echo "$sql" | tail -n 3
    echo

    echo "dataPath: $data_path"
    echo "---$msg tb $tbName in db $dbName for $cpTimes times---"
    sleep 3

    echo "$sql" | $MEGAWISE_HOME/bin/psql -f - $dbName
}

function sqlCopy(){
    filename=$1
    echo "`date +%Y%m%d-%H:%M:%S`,copy start for $filename"

    $MEGAWISE_HOME/bin/psql --dbname=$dbName --username=$USER<<EOF
\timing on
copy $tbName FROM '$filename' WITH CSV HEADER ;
EOF
    echo "`date +%Y%m%d-%H:%M:%S`,copy end for $filename"
}

function bgload() {
    for((i=0;i<$cpTimes;i++));do
	j=0
	pids=""
	for filename in $data_path/50m_{1..23}.csv; do
	    let j+=1
	    sqlCopy $filename &
	    pids="$pids $!"
	    let mod=j%4
	    if [ $mod -eq 0];then
		echo "echo one job finished"
		wait $pids
	    fi
	done

	echo "echo all jobs finished"
	wait
    done
}

function fgload() {
    for((i=0;i<$cpTimes;i++));do
	for filename in $data_path/50m_{1..23}.csv; do
	    sqlCopy $filename
	    echo
	    echo
	done

	echo
	echo
    done
}

function main() {
    tableOps
    if [ X$multiload != X ];then
	bgload
    else
	fgload
    fi
}

main
