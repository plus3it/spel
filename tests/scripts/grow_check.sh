#!/bin/bash
#
set -euo pipefail
#
# Script to exercise growing the partition containing the "/" filesystem
#
################################################################################


ROOT_DEV="$( grep ' / ' /proc/mounts | cut -d " " -f 1 )"

# Extract physical disk device from LVM2 VG
if [[ ${ROOT_DEV} == /dev/mapper/* ]]
then
  ROOT_VOLGRP="$( sed -e 's#/dev/mapper/##' -e 's/-.*$//' <<< "${ROOT_DEV}" )"
  ROOT_DSKPRT="$(
    pvdisplay -S vgname="${ROOT_VOLGRP}" | \
    awk '/PV Name/{ print $3 }'
  )"
fi

# Separate "/"-hosting partition from base device
if [[ ${ROOT_DSKPRT} == /dev/nvme* ]]
then
  ROOT_DISK="${ROOT_DSKPRT//p*/}"
  ROOT_PART="${ROOT_DSKPRT//*p/}"
elif [[ ${ROOT_DSKPRT} == /dev/xvd* ]]
then
  echo "Xen Virtual Disk devices not supported"
  exit 1
fi

SEL_MODE="$( getenforce )"

# Run the grow-part task
[[ -d /sys/fs/selinux ]] && setenforce Permissive 
growpart "${ROOT_DISK}" "${ROOT_PART}"
[[ -d /sys/fs/selinux ]] && setenforce "${SEL_MODE}"
