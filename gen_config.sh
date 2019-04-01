#!/bin/bash

#log level default value
LOGLEVEL=3  #warn
while getopts "d:l:h" arg
do
        case $arg in
             d) # data_path
                PGDATA=$OPTARG
                ;;
             l) # log_level
                LOGLEVEL=$OPTARG
                if [ $LOGLEVEL -gt 5 ] || [ $LOGLEVEL -lt 0 ];then
                    LOGLEVEL=0
                fi
                ;;
             h) # help
                echo "

parameter:
-h: help
-l: set log level, range [0,5], default 0
-d: database storage path

usage:
./gen_config.sh -d \${PGDATA} [-h]
./gen_config.sh -d \${PGDATA} -l 2
                "
                exit 0
                ;;
             ?)
                echo "unkonw argument"
        exit 1
        ;;
        esac
done

if [ -z "$PGDATA" ]; then
    echo "Need to set PGDATA"
    exit 1
fi

CFG_FILE=${PGDATA}/zdb_config.yaml

touch $CFG_FILE
sed -i -n '' $CFG_FILE

echo 'print_result_header: true' >>  $CFG_FILE
echo 'force_print_plan: false' >>  $CFG_FILE
echo 'export_visual_plan: 0' >>  $CFG_FILE

echo 'log_config:' >>  $CFG_FILE
echo '  path: '${PGDATA}/megawise_log  >>  $CFG_FILE
echo '  level: '${LOGLEVEL}  >>  $CFG_FILE
echo '  rotating: yes' >>  $CFG_FILE
echo '  rotating_size_limit: 64' >>  $CFG_FILE
echo '  rotating_number_limit: 10' >>  $CFG_FILE

echo 'service_config:' >>  $CFG_FILE
echo '  server_address: 127.0.0.1:21001' >>  $CFG_FILE
echo '  client_address: 127.0.0.1:0' >>  $CFG_FILE
echo '  transfer_protocol: 5' >>  $CFG_FILE
echo '  long_connection: false' >>  $CFG_FILE
