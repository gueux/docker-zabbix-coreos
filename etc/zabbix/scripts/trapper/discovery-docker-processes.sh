#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"
KEY=${KEY:-"docker.discovery.processes"}
VALUE=$(${BASH_SOURCE%/*}/../discovery/docker-processes.sh)
if [ "$?" -ne "0" ]; then
   exit 1
fi
zbx_send "$KEY" "$VALUE"
