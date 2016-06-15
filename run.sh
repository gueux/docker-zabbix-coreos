#!/bin/bash

if [ ! -d  '/hostfs' ]
then
  echo "/hostfs is not mounted"
  exit 1
fi

if [ -z "$ZBX_Server" ]; then
    echo "Server address is missing"
    exit 1
fi

if [ -z "$ZBX_Hostname" ]; then
   if [ -f /hostfs/etc/hostname ]
   then
       ZBX_Hostname=$(cat /hostfs/etc/hostname)
   else
       ZBX_Hostname=$(hostname -f)
   fi
fi

for VARIABLE_NAME in $(compgen -A variable)
do
  if [[ ${VARIABLE_NAME} == ZBX_* ]]
  then
    OPTION_NAME=${VARIABLE_NAME#ZBX_}
    OPTION_VALUE=${!VARIABLE_NAME}
    sed -i "s/^$OPTION_NAME\=.*/$OPTION_NAME\=$OPTION_VALUE/" /etc/zabbix/zabbix_agentd.conf
  fi
done

if [ -f "/etc/zabbix/$HOST.conf" ]; then
    cat "/etc/zabbix/$HOST.conf" >> /etc/zabbix/zabbix_agentd.conf
fi

exec "$@"
