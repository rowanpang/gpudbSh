#!/bin/bash

SERVER_DATA=""
MEGAWISE_CONFIG=""
TEMPLATE_MEGAWISE_CONFIG=""
LOG_PATH=""
FORCE=false

while getopts "d:t:o:l:fh" arg
do
        case $arg in
             d) # server data storage path
                SERVER_DATA=$OPTARG
                ;;
             o) # megawise configure file output path
                MEGAWISE_CONFIG=$OPTARG
                ;;
             t) # megawise template configure file input path
                TEMPLATE_MEGAWISE_CONFIG=$OPTARG
                ;;
             l) # megawise log file path
                LOG_PATH=$OPTARG
                ;;
             f) # force delete database storage path
                FORCE=true
                ;;
             h) # help
                echo "

parameter:
-h: help
-d: server data storage path
-o: megawise configure file output path
-t: megawise template megawise configure file input path
-l: megawise log file path
-f: force delete database storage path

usage:
./gen_megawise_config.sh -d \${SERVER_DATA} -t \${TEMPLATE_MEGAWISE_CONFIG} -o \${MEGAWISE_CONFIG} -l \${LOG_PATH} [-f] [-h]
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
ROOT_LIB_PATH=${ROOTPATH}/lib
TEMPLATE_CONF_PATH=${ROOTPATH}/conf

if [[ ! -n ${TEMPLATE_MEGAWISE_CONFIG} || ${TEMPLATE_MEGAWISE_CONFIG} == "" ]]; then
  TEMPLATE_MEGAWISE_CONFIG=${TEMPLATE_CONF_PATH}/megawise_config_template.yaml
fi

if [[ ! -n ${MEGAWISE_CONFIG} || ${MEGAWISE_CONFIG} == "" ]]; then
  MEGAWISE_CONFIG=${ROOTPATH}/conf/megawise_config.yaml
fi

MEGAWISE_CONFIG_PATH=${MEGAWISE_CONFIG%/*}
if [[ ! -d ${MEGAWISE_CONFIG_PATH} ]]; then
  mkdir -p ${MEGAWISE_CONFIG_PATH}
fi

if [[ ! -n ${SERVER_DATA} || ${SERVER_DATA} == "" ]]; then
  SERVER_DATA=${ROOTPATH}/server_data
fi

if [[ ! -n ${LOG_PATH} || ${LOG_PATH} == "" ]]; then
  LOG_PATH="/tmp"
fi
if [[ ! -d ${LOG_PATH} ]]; then
  mkdir -p ${LOG_PATH}
fi

if [[ -f ${MEGAWISE_CONFIG} ]]; then
  if [[ ${FORCE} == false ]]; then
    QUIT_COMMAND="Y"
    until [ "$USER_INPUT" = "$QUIT_COMMAND" ]
    do
      echo "
  The \" ${MEGAWISE_CONFIG} \" already exists!
  Do you want to delete it? Enter (\"Y\"/\"n\"/\"quit\")."
      read USER_INPUT
      case ${USER_INPUT} in
         "Y")
                 rm ${MEGAWISE_CONFIG}
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
  else
    rm ${MEGAWISE_CONFIG}
  fi
fi
cp ${TEMPLATE_MEGAWISE_CONFIG} ${MEGAWISE_CONFIG}

sed -i "s|@bitcode_lib@|${ROOT_LIB_PATH}|g" ${MEGAWISE_CONFIG}
sed -i "s|@db_path@|${SERVER_DATA}|g" ${MEGAWISE_CONFIG}
sed -i "s|@log_path@|${LOG_PATH}|g" ${MEGAWISE_CONFIG}

