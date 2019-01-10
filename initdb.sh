#!/bin/bash

DB_NAME="postgres" # default postgres
PORT="5432"  # default 5432
DATAPATH=${PGDATA}
FORCE=false

while getopts "p:n:d:fh" arg
do
        case $arg in
             p) # port
                PORT=$OPTARG
                ;;
             n) # db_name
                DB_NAME=$OPTARG
                ;;
             d) # data_path
                DATAPATH=$OPTARG
                ;;
             f) # force delete database storage path
                FORCE=true
                ;;
             h) # help
                echo "

parameter:
-h: help
-p: postgres port
-n: database name
-d: database storage path
-f: force delete database storage path

usage:
./initdb.sh -p \${PORT} -n \${DB_NAME} -d \${DATAPATH} [-f] [-h]
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

source ${ROOTPATH}/script/megawise_env.sh

if [[ ! -n ${DATAPATH} ]];then
  DATAPATH=${ROOTPATH}/data
fi


if [[ ${FORCE} == false ]];then
  QUIT_COMMAND="Y"
  if [[ -d "${DATAPATH}" ]];then
    until [ "$USER_INPUT" = "$QUIT_COMMAND" ]
    do
      echo "
  The \" ${DATAPATH} \" already exists!
  Do you want to delete it? Enter (\"Y\"/\"n\"/\"quit\")."
      read USER_INPUT
      case ${USER_INPUT} in
         "Y")
                 rm -rf ${DATAPATH}
                 ;;
         "n")
                 exit 0
                 ;;
      "quit")
                 exit 0
                 ;;
           *)
                 ;;
      esac
    done
  fi
else
  if [[ -d "${DATAPATH}" ]];then
    rm -rf ${DATAPATH}
  fi
fi

mkdir ${DATAPATH}
${ROOTPATH}/bin/initdb ${DATAPATH}
export PGDATA=${DATAPATH}
cat "${ROOTPATH}/script/append_config.sh"  >> ${PGDATA}/postgresql.conf
echo "port = ${PORT}" >> ${PGDATA}/postgresql.conf
. ${ROOTPATH}/script/gen_config.sh
${ROOTPATH}/script/start_server.sh
if [[ ${DB_NAME} != "postgres" ]];then
  $ROOTPATH/bin/createdb -p ${PORT} ${DB_NAME}
fi
$ROOTPATH/bin/psql -p ${PORT} -f ${ROOTPATH}/sql/create_server.sql ${DB_NAME}
${ROOTPATH}/script/stop_server.sh
