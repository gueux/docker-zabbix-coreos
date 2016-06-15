#!/usr/bin/env bash
cd /sys/class/block
for dev in *
do
  if  [[ ${dev} == loop* ]] || [[ ${dev} == ram* ]] || [[ ${dev} == sr* ]]
  then
    continue
  fi
  DATA="$DATA,"'{"{#DEVICENAME}":"'$dev'"}'
done
echo '{"data":['${DATA#,}']}'
