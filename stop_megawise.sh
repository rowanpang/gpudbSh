#!/bin/bash

function kill_progress()
{
  pcount=$(pgrep -f $1 | wc -l)
  if [[ ${pcount} -ne 0 ]];then
    kill -s SIGUSR2 $(pgrep $1)

    for i in {1..20}
    do
      if [[ ${pcount} -eq 0 ]];then
        break
      fi
      sleep 1
      pcount=$(pgrep -f $1 | wc -l)
    done
  fi

  if [[ ${pcount} -ne 0 ]];then
    echo "false"
  else
    echo "true"
  fi
}

STATUS=$(kill_progress "megawise_server" )

if [[ ${STATUS} == "false" ]];then
  echo "megawise_server kill failure!"
else
  echo "megawise_server kill success!"
fi

