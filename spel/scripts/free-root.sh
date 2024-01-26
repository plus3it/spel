#!/bin/bash

# Try to capture all system output
exec 1> >( logger -s -t "$(  basename "${0}" )" ) 2>&1

echo "Restarting systemd"
systemctl daemon-reexec

echo "Killing auditd"
service auditd stop

echo "Kill all non-essential services"
for SERVICE in $(
  systemctl list-units --type=service --state=running | \
  awk '/loaded active running/{ print $1 }' | \
  grep -Ev '(sshd|user@)'
)
do
  echo "Killing ${SERVICE}"
  systemctl stop "${SERVICE}"
done

echo "Sleeping to allow everything to stop"
sleep 10

echo Killing processes locking /oldroot
fuser -vmk /oldroot
