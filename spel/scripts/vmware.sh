#!/bin/bash

# Bail if we are not running inside VMWare.
if [[ "$(virt-what | head -1)" != "vmware" ]]; then
    exit 0
fi

# Install the VMWare Tools from a linux ISO.
echo "installing vmware tools"

#wget http://192.168.0.185/linux.iso -P /tmp
mkdir -p /mnt/vmware
mount -o loop /home/vagrant/linux.iso /mnt/vmware

cd /tmp || exit 1
tar xzf /mnt/vmware/VMwareTools-*.tar.gz

umount /mnt/vmware
rm -fr /home/vagrant/linux.iso

/tmp/vmware-tools-distrib/vmware-install.pl -d
rm -fr /tmp/vmware-tools-distrib
