#!bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
filepath=${DIR%/*}
export PG_HOME=$filepath
export PATH=$PG_HOME/bin:$PATH
export CUDA_VISIBLE_DEVICES=0

LD_LIBRARY_PATH="/usr/local/gcc-6.3.0/lib64/"
if [ ! -n $LD_LIBRARY_PATH ]; then
  export LD_LIBRARY_PATH=$PG_HOME/lib:/usr/local/lib
else
  export LD_LIBRARY_PATH=$PG_HOME/lib:$LD_LIBRARY_PATH:/usr/local/lib
fi

export CUDA_VISIBLE_DEVICES=0
