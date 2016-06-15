#!/usr/bin/env bash
cd /sys/class/block
for dev in *
do
  if  [[ ${dev} == loop* ]] || [[ ${dev} == ram* ]] || [[ ${dev} == sr* ]]
  then
    continue
  fi
  RES="$RES\n- custom.vfs.dev.read.ops[$dev] "$(awk '{print $1}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.read.merged[$dev] "$(awk '{print $2}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.read.sectors[$dev] "$(awk '{print $3}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.read.ms[$dev] "$(awk '{print $4}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.write.ops[$dev] "$(awk '{print $5}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.write.merged[$dev] "$(awk '{print $6}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.write.sectors[$dev] "$(awk '{print $7}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.write.ms[$dev] "$(awk '{print $8}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.io.active[$dev] "$(awk '{print $9}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.io.ms[$dev] "$(awk '{print $10}' /hostfs/sys/class/block/$dev/stat)
  RES="$RES\n- custom.vfs.dev.weight.io.ms[$dev] "$(awk '{print $11}' /hostfs/sys/class/block/$dev/stat)
done
zbx_send_all "$RES"
