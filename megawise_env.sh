#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
ROOTPATH=${DIR%/*}

if [[ ! -n ${PGDATA} ]];then
  export PGDATA=${ROOTPATH}/data
fi

GCC_6_3_LIB="/usr/local/gcc-6.3.0/lib64"
export PG_HOME=${ROOTPATH}
export PATH=${PG_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${PG_HOME}/lib:"$GCC_6_3_LIB":$LD_LIBRARY_PATH
