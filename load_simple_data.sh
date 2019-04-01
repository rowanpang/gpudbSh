#!/bin/bash

# usage: ./load_simple_data.sh -h

#-------------------
# CUSTOMIZED OPTIONS
DB="test" # Default DB
PORT="5432" # Default Port
HOME_DIR="/usr/local/megawise"

#-------------------
# Default Global Variables
recreate=0 # Recreate DB if 1
#-------------------

#-------------------
# handle input parms
while [ -n "$1" ]
do
  case "$1" in
    -m) # megawise home directory
        HOME_DIR=($2)
        shift
        ;;
    -p) # port
        PORT=($2)
        shift
        ;;
    -t) # test table
        ltable=($2)
        shift
        ;;
    -d) # db name
        DB=$2
        shift
        ;;
    -s) # sql dircetory
        SQLDIR=$2
        shift
        ;;
    -i) # import data path
        IMPORTDATA_PATH=$2
        shift
        ;;
    -rd) # recreate DB
        DB=$2
        recreate=1
        shift
        ;;
    -h) # help
        echo "
parameter:
-m: megawise home directory
-p: postgres port
-t: load table name.
-d: database name.
-s: sql dircetory
-i: import data path
-rd: recreate db

usage:
./load_simple_data.sh -m \${HOME_DIR} -p \${PORT} -t \${TABLE_NAME} -s \${SQLDIR} -i \${IMPORTDATA_PATH} [-d|-rd] \${DATABASE_NAME} [-h]"
            exit 1;
        ;;
    *)
        echo "$1 is not an option;"
            exit 1;
        ;;
  esac
  shift
done
#-------------------


# Main
######################
if [[ ! -d ${HOME_DIR} ]];then
  echo "${HOME_DIR} does not exist!"
  exit 1
fi

PSQL="${HOME_DIR}/bin/psql -d $DB -p $PORT  -c "\\timing" -q -b "
source ${HOME_DIR}/script/megawise_env.sh

if [[ ! -n ${SQLDIR} ]];then
  SQLDIR="${HOME_DIR}/sql"
fi

if [[ ! -n ${IMPORTDATA_PATH} ]];then
  IMPORTDATA_PATH="${HOME_DIR}/csv"
fi

echo -e "START TEST: \n"

# createDB
if [ $recreate -eq 1 ];then
  ${HOME_DIR}/bin/dropdb $DB -p $PORT
  if [ $? -eq 0 ];then
    echo "Drop ${DB} database success ..."
  else
    echo "Drop ${DB} database failed ..."
    exit 1
  fi
fi

${HOME_DIR}/bin/createdb $DB -p $PORT
if [ $? -eq 0 ];then
  # $PSQL -f $SQLDIR/plugin.sql
  echo "Create ${DB} database success ..."
else
  echo "Create ${DB} database failed ..."
fi

TOTAL_SECS=0 # record start time

# create Tables
SECONDS=0
for table in ${ltable[@]}
do
  echo "Create ${table} table ..."
  $PSQL -f $SQLDIR/create_table/${table}.sql
done
echo "Table-Creation: $SECONDS secs"
TOTAL_SECS=$(($TOTAL_SECS + $SECONDS))

# load csv data
SECONDS=0
for table in ${ltable[@]}
do
  for file in `ls ${IMPORTDATA_PATH}/${table}*.csv`
  do
    echo "Load table ${table} from ${file}"
    $PSQL -c "COPY ${table} FROM '${file}' WITH CSV;"
  done
done
echo "Load-Tables: $SECONDS secs"

TOTAL_SECS=$(($TOTAL_SECS + $SECONDS))
echo "Total: $TOTAL_SECS secs"

