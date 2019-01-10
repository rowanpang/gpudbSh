#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source ${DIR}/zdb.sh 

if [  -d "${PG_HOME}/logfile" ]; then
rm -f ${PG_HOME}/logfile
fi

export CUDA_VISIBLE_DEVICES=0
echo "CUDA_VISIBLE_DEVICES= $CUDA_VISIBLE_DEVICES"

node=8

if [ $node -eq 0 ];then
	cpuset="0-79"
else
	cpuset="80-159"
fi

numactl -N $node -m $node $PG_HOME/bin/pg_ctl -D $PG_HOME/data -l $PG_HOME/logfile start
postmaster_pid=$(pidof postgres | xargs -n1 | sort | head -n1)
taskset -pc $cpuset $postmaster_pid
pidof postgres -o $postmaster_pid | xargs -n1 taskset -pc $cpuset
