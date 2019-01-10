#!/bin/bash

. path.sh

if [  -d "${PGDATA}" ]; then
rm -rf ${PGDATA}
fi

mkdir ${PGDATA}
$PG_HOME/bin/initdb ${PGDATA}
echo "shared_preload_libraries = 'zdb_fdw'" >> ${PGDATA}/postgresql.conf
echo "client_min_messages = error" >> ${PGDATA}/postgresql.conf
echo "enable_mergejoin = off" >> ${PGDATA}/postgresql.conff
echo "enable_nestloop = off" >> ${PGDATA}/postgresql.conf
echo "enable_material = off" >> ${PGDATA}/postgresql.conf

. cpu_info.sh

${PG_HOME}/script/server_start.sh
$PG_HOME/bin/createdb -h /tmp test
$PG_HOME/bin/psql -h /tmp -f ${PG_HOME}/script/sql/create_server.sql test
${PG_HOME}/script/server_stop.sh
