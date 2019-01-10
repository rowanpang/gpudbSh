#!/bin/bash

PORT="5432"  # default 5432
DB_NAME="postgres" # default postgres


while getopts "p:n:h" arg
do
        case $arg in
             p) # port
                PORT=$OPTARG
                ;;
             n) # db_name
                DB_NAME=$OPTARG
                ;;
             h) # help
                echo "

parameter:
-h: help
-p: postgres port
-n: database name

usage:
./initdb.sh -p \${PORT} -n \${DB_NAME} [-h]
                "
                exit 0
                ;;
             ?)
                echo "unkonw argument"
        exit 1
        ;;
        esac
done

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
ROOTPATH=${DIR%/*}

${ROOTPATH}/bin/psql -p ${PORT} -n ${DB_NAME}
