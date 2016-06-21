#!/usr/bin/env bash
SOURCE_DIR=$(realpath $(dirname "${BASH_SOURCE[0]}"))
CURRENT_DIR=$(pwd)
VERSION=${VERSION:-3.0.3} # 3.0.2,3.0.3, maybe higher

## Download source
cd /tmp \
  && wget -O zabbix-${VERSION}.tar.gz "http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/${VERSION}/zabbix-${VERSION}.tar.gz" \
  && tar -zxf zabbix-${VERSION}.tar.gz \
  && rm -f zabbix-${VERSION}.tar.gz \
  && cd /tmp/zabbix-${VERSION}/ \
  && patch --verbose -p1 < ${SOURCE_DIR}/zabbix-3.0.3-docker.patch \
  && patch --verbose -p1 < ${SOURCE_DIR}/zabbix-3.0.3-cidr.patch \
  && cd /tmp \
  && tar -zcf zabbix-${VERSION}.patched.tar.gz zabbix-3.0.3 \
  && mv zabbix-${VERSION}.patched.tar.gz ${CURRENT_DIR}/zabbix-${VERSION}.patched.tar.gz \
  && echo "./zabbix-${VERSION}.patched.tar.gz"
