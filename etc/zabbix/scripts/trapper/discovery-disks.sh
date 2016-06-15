#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../main"
KEY=${KEY:-"custom.vfs.discover_disks"}
VALUE=$(${BASH_SOURCE%/*}/../discovery/disks.sh)
if [ "$?" -ne "0" ]; then
   exit 1
fi
zbx_send "$KEY" "$VALUE"
