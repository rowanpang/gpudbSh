#!/bin/bash

MEGAWISE_CONFIG=""

while getopts "c:h" arg
do
        case $arg in
             c) # megawise configure file path
                MEGAWISE_CONFIG=$OPTARG
                ;;
             h) # help
                echo "

parameter:
-h: help
-c: megawise configure file path

usage:
./start_megawise.sh -c \${MEGAWISE_CONFIG} [-h]
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

if [ -d ${ROOT_LIB_PATH} ]; then
  export LD_LIBRARY_PATH=${ROOT_LIB_PATH}:${LD_LIBRARY_PATH}
else
  export LD_LIBRARY_PATH=${ROOT_LIB_PATH}
fi

if [[ ! -n ${MEGAWISE_CONFIG} || ${MEGAWISE_CONFIG} == "" ]];then
  MEGAWISE_CONFIG=${ROOTPATH}/conf/megawise_config.yaml
fi

${ROOTPATH}/bin/megawise_server -c ${MEGAWISE_CONFIG} &

echo "waiting...."
sleep 30
echo "finished"
