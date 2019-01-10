#!/bin/bash

#data_path=/data/workspace/data/split
#$PG_HOME/bin/psql -f ${PG_HOME}/script/sql/create_trips_table.sql postgres
data_path=/home/data/NYC_TAXI/rowan
#$PG_HOME/bin/psql -f ${PG_HOME}/script/sql/create_trips_table.sql test
#for filename in $data_path/*.csv; do
#done

for filename in $data_path/*.csv; do
	$PG_HOME/bin/psql --dbname=test --username=inspur <<AAAA
\timing 
\COPY tripsone FROM $filename WITH CSV HEADER ;
AAAA
done

#$PG_HOME/bin/psql --dbname=test --username=inspur <<AAAA
#\timing 
#\COPY trips FROM /home/data/NYC_TAXI/data/50m_1.csv WITH CSV HEADER ;
#AAAA
