#!/bin/bash
dbName="postgres"
tbName="trips"
cpTimes=1
doAppend=1

data_basedir=$HOME/NYC_TAXI
data_path=$data_basedir/rowan

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
    	*)
	    echo "---args error----"
 	    echo "usage:$0 -t[tb/$tbName]/-d[db/$dbName]/-n[cpTimes]/-r[reCreate not append]/-f[full csv]" 
	    echo "---default is append data to $tbName table in db $dbName----"
	    exit
	    ;;
    esac
    shift
done

	
sqlCreateOrg=`cat ${PG_HOME}/script/sql/create_trips_table.sql`
if [ "$doAppend" -eq 1 ];then
    sql=`echo "$sqlCreateOrg" | sed '1d' | sed "1s/trips/IF NOT EXISTS $tbName/"`
    msg="doAppend"
else
    sql=`echo "$sqlCreateOrg" | sed "1,2s/trips/$tbName/"`
    msg="reCreate"
fi
echo "$sql" | head -n 3
echo "........"
echo "$sql" | tail -n 3
echo "using data: $data_path"
echo "---$msg tb $tbName in db $dbName for $cpTimes times---"
sleep 3

echo "$sql" | $PG_HOME/bin/psql -f - $dbName

for i in `seq 1 $cpTimes`;do
    for filename in $data_path/*.csv; do
	echo "`date +%Y%m%d-%H:%M:%S`,file:$filename"
	$PG_HOME/bin/psql --dbname=$dbName --username=$USER<<EOF
\timing on
copy $tbName FROM '$filename' WITH CSV HEADER ;
EOF
    done

    echo
    echo
done
