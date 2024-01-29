#!/bin/bash
#
# Script to more-thorougly clear out processes that may be holding the boot-
# disk open
#
################################################################################

set -x
set -e

echo "Restarting systemd"
systemctl daemon-reexec

echo "Killing auditd"
service auditd stop

echo "Kill all non-essential services"
for SERVICE in $(
  systemctl list-units --type=service --state=running | \
  awk '/loaded active running/{ print $1 }' | \
  grep -Ev '(audit|sshd|user@)'
)
do
  echo "Killing ${SERVICE}"
  systemctl stop "${SERVICE}"
done

echo "Sleeping to allow everything to stop"
sleep 10

echo Killing processes locking /oldroot
fuser -vmk /oldroot
