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

# The auditd (UpStart) service may or may not be running...
if [[ $( service auditd status > /dev/null 2>&1 )$? -eq 0 ]]
then
  echo "Killing auditd"
  service auditd stop
else
  echo "The auditd service is not running"
fi

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
