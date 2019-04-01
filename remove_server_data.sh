#!/bin/bash

SERVER_DATA=""
FORCE=false

while getopts "d:c:fh" arg
do
        case $arg in
             d) # server data storage path
                SERVER_DATA=$OPTARG
                ;;
             c) # megawise configure file path
                MEGAWISE_CONFIG=$OPTARG
                ;;
             f) # force delete megawise server storage path
                FORCE=true
                ;;
             h) # help
                echo "

parameter:
-h: help
-d: megawise server storage path
-c: megawise configure file path
-f: force delete megawise server storage path

usage:
./remove_server_data.sh -d \${SERVER_DATA} -c \${MEGAWISE_CONFIG} [-f] [-h]
                "
                exit 0
                ;;
             ?)
                echo "unkonw argument"
        exit 1
        ;;
        esac
done

if [[ -n ${MEGAWISE_CONFIG} && -f ${MEGAWISE_CONFIG} ]];then
  STORAGE_CONFIG_LABEL="storage_config:"
  DB_PATH_LABEL="db_path:"
  
  STORAGE_CONFIG_FNR=`awk "/${STORAGE_CONFIG_LABEL}/{print FNR}" ${MEGAWISE_CONFIG}`
  SERVER_DATA_CONFIG=`awk 'NR>'${STORAGE_CONFIG_FNR}' && /'${DB_PATH_LABEL}'/{print $2}' ${MEGAWISE_CONFIG}`
fi

if [[ -n ${SERVER_DATA_CONFIG} && -d ${SERVER_DATA_CONFIG} ]];then
  SERVER_DATA=${SERVER_DATA_CONFIG}
fi

QUIT_COMMAND="Y"
if [[ -n ${SERVER_DATA} && -d ${SERVER_DATA} ]];then
  if [[ ${FORCE} == false ]];then
    until [ "$USER_INPUT" = "$QUIT_COMMAND" ]
    do
      echo "
The \" ${SERVER_DATA} \" already exists!
Do you want to delete it? Enter (\"Y\"/\"n\"/\"quit\")."
      read USER_INPUT
      case ${USER_INPUT} in
         "Y")
                 echo "Delete \" ${SERVER_DATA} \" ..."
                 rm -rf ${SERVER_DATA}
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
    echo "Delete \" ${SERVER_DATA} \" ..."
    rm -rf ${SERVER_DATA}
  fi
else
  echo "The \" ${SERVER_DATA} \" dircetory does not exist!"
fi

