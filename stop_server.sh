#!/bin/bash

while getopts "d:l:h" arg
do
        case $arg in
             d) # postgres data path
                PGDATA=$OPTARG
                ;;
             h) # help
                echo "

parameter:
-h: help
-d: postgres data path

usage:
./stop_server.sh -d \${PGDATA} [-h]
                "
                exit 0
                ;;
             ?)
                echo "unkonw argument"
        exit 1
        ;;
        esac
done

if [[ -z "${PGDATA}" ]];then
  echo "Environment variable 'PGDATA' does not exist."
  exit 1
fi

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
ROOTPATH=${DIR%/*}

${ROOTPATH}/bin/pg_ctl -D ${PGDATA} stop
