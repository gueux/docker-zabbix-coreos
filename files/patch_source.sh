#!/usr/bin/env bash
SOURCE_DIR=$(realpath $(dirname "${BASH_SOURCE[0]}"))
CURRENT_DIR=$(pwd)

echo "${SOURCE_DIR}/files/zabbix-docker-3.0.3.patch"

## Download source
cd /tmp \
  && wget -O zabbix-3.0.3.tar.gz 'http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.3/zabbix-3.0.3.tar.gz' \
  && tar -zxvf zabbix-3.0.3.tar.gz \
  && rm -f zabbix-3.0.3.tar.gz \
  && cd /tmp/zabbix-3.0.3/ \
  && patch --verbose -p1 < ${SOURCE_DIR}/zabbix-docker-3.0.3.patch \
  && cd /tmp \
  && tar -zcvf zabbix-3.0.3.patched.tar.gz /tmp/zabbix-3.0.3 \
  && mv zabbix-3.0.3.patched.tar.gz ${CURRENT_DIR}/zabbix-3.0.3.patched.tar.gz
