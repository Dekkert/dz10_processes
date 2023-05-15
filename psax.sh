#!/bin/bash

_pid(){
  echo "${PROC_PID/\/proc\//}"
}

_stat(){
  if [ -f ${PROC_PID}/stat ]; then
    cat ${PROC_PID}/stat | rev | awk '{printf $50}' | rev
  else
    echo 'n/a'
  fi
}

_time(){
  if [ -f ${PROC_PID}/stat ]; then
    cat ${PROC_PID}/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print sum/100}' | awk '{("date +%M:%S -d @"$1)| getline $1}1'
  else
    echo 'n/a'
  fi
}

_command(){
  if [ -f ${PROC_PID}/stat ]; then
  # предупреждение: подстановка команды: во входных данных проигнорирован нулевой байт
    cat ${PROC_PID}/cmdline | tr '\0' '\n' | sed -e s/DBUS_SESSION_BUS_ADDRESS=//
  else
    echo 'n/a'
  fi
}

for PROC_PID in `ls -d /proc/* | egrep "^/proc/[0-9]+"`; do
  echo $(_pid) $(_stat) $(_time) $(_command);
done
