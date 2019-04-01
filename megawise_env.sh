#!bin/bash

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

LIBCUDA="/usr/local/cuda-9.1/lib64"
LIBGCC="/usr/local/gcc-6.3.0/lib64"
LIBBOOST="/usr/local/boost-1.67.0/lib"

export MEGAWISE_HOME=${ROOTPATH}
export PATH=${MEGAWISE_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${MEGAWISE_HOME}/lib:$LIBCUDA:$LIBGCC:$LIBBOOST:$LD_LIBRARY_PATH
