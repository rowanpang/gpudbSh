#!/bin/bash

if [ -z "$PGDATA" ]; then
    echo "Need to set PGDATA"
    exit 1
fi

CFG_FILE=${PGDATA}/zdb_config.yaml

#lscpu | grep 'Thread(s) per core\|Core(s) per socket\|Socket(s)\|NUMA node(s)' | cut -f 2 -d ':'
thread_per_core=`lscpu | grep 'Thread(s) per core' | cut -f 2 -d ':' | xargs`
core_per_socket=`lscpu | grep 'Core(s) per socket' | cut -f 2 -d ':' | xargs`
socket=`lscpu | grep 'Socket(s)' | cut -f 2 -d ':' | xargs`
numa_node=`lscpu | grep 'NUMA node(s)' | cut -f 2 -d ':' | xargs`


touch $CFG_FILE
sed -i -n '/thread_per_core/d' $CFG_FILE
sed -i -n '/core_per_socket/d' $CFG_FILE
sed -i -n '/socket/d' $CFG_FILE
sed -i -n '/numa_node/d' $CFG_FILE
sed -i -n '/result_print_limit/d' $CFG_FILE
sed -i -n '/cache_memory_limit/d' $CFG_FILE
sed -i -n '/log_min_level/d' $CFG_FILE
sed -i -n '/display_debug_log/d' $CFG_FILE

grep -s -w 'thread_per_core' $CFG_FILE || echo 'thread_per_core: '$thread_per_core >> $CFG_FILE
grep -s -w 'core_per_socket' $CFG_FILE || echo 'core_per_socket: '$core_per_socket >> $CFG_FILE
grep -s -w 'socket' $CFG_FILE || echo 'socket: '$socket >> $CFG_FILE
grep -s -w 'numa_node' $CFG_FILE || echo 'numa_node: '$numa_node >> $CFG_FILE
echo 'result_print_limit: -1' >>  $CFG_FILE
echo 'cache_memory_limit: 70' >>  $CFG_FILE
echo 'log_min_level: 0' >>  $CFG_FILE
echo 'display_debug_log: 0' >>  $CFG_FILE
echo 'force_print_plan: true' >>  $CFG_FILE
echo 'export_visual_plan: 2' >>  $CFG_FILE
echo 'support_native: false' >>  $CFG_FILE
echo 'engine_config:' >>  $CFG_FILE
echo '  agg_bucket_size: 16384' >>  $CFG_FILE
echo '  grid_dim_x: 40' >>  $CFG_FILE
echo '  grid_block_x: 256' >>  $CFG_FILE
