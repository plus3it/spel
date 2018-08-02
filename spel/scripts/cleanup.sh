#!/bin/bash

# Remove deps no longer needed
REMOVE_DEPS="virt-what"
yum -y remove --setopt=clean_requirements_on_remove=1 ${REMOVE_DEPS} >/dev/null

# Generate RPM manifest
rpm -qa | sort -u > /tmp/manifest.txt

# Remove yum artifacts
yum --enablerepo=* clean all >/dev/null
rm -rf /var/cache/yum
rm -rf /var/lib/yum

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm -f /var/lib/dhclient/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

# Ensure unique SSH hostkeys
echo "generating new ssh hostkeys"
shred -uz /etc/ssh/*key*
service sshd restart

# Clean out miscellaneous log files
for FILE in boot.log btmp cloud-init.log cloud-init-output.log cron dmesg \
    dmesg.old dracut.log lastlog maillog messages secure spooler tallylog \
    wtmp yum.log rhsm/rhsmcertd.log rhsm/rhsm.log sa/sa22
do
    if [[ -e /var/log/$FILE ]];
    then
        cat /dev/null > /var/log/${FILE}
    fi
done

# Clean out audit logs
find -L /var/log/audit -type f -print0 | xargs -0 shred -uz

# Clean out root's history buffers and files
echo "cleaning shell history"
history -c ; cat /dev/null > /root/.bash_history
