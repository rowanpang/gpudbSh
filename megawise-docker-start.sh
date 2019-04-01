#!/bin/bash

set -e

while getopts "d:h" arg
do
        case $arg in
             d) # database storage directory
                STORAGE_DIR=$OPTARG
                ;;
             h) # help
                echo "

parameter:
-h: help
-d: database storage directory path

usage:
./megawise-docker-start -d \${STORAGE_DIR} [-h]
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

if [[ "$(whoami)" == "root" ]]; then
    mkdir -p ${STORAGE_DIR} && chown -R megawise:megawise ${STORAGE_DIR}
fi

# Switch to the megawise user (without --login)
if [[ "$(whoami)" != "megawise" ]]; then
    su megawise -c "$0 $@"
fi

if [[ "$(whoami)" == "megawise" ]]; then
    source ${ROOTPATH}/script/megawise_env.sh

    ${ROOTPATH}/script/initdb.sh -d ${STORAGE_DIR}/data -i
    echo "listen_addresses = '*'" | tee -a ${STORAGE_DIR}/data/postgresql.conf
    echo "host    all             all             0.0.0.0/0               trust" | tee -a ${STORAGE_DIR}/data/pg_hba.conf
    ${ROOTPATH}/script/gen_megawise_config.sh -d ${STORAGE_DIR}/server_data -l ${STORAGE_DIR}/server_data/logs -o ${STORAGE_DIR}/megawise_config.yaml
    ${ROOTPATH}/script/start_server.sh -d ${STORAGE_DIR}/data
    ${ROOTPATH}/script/start_megawise.sh -c ${STORAGE_DIR}/megawise_config.yaml
fi

while true; do
    sleep 30
done
