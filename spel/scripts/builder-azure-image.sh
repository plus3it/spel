#!/bin/bash
#
# Script to create a custom image from which to later create a spel image.
# This script expects an Azure marketplace EL7 offer, publisher, sku that does
# not have cloud-init configured.  The script will install and configure
# cloud-init in the resultant custom image which is to be used in subsequent
# execution for spel image creation.
#
##############################################################################
set -eu -o pipefail

HTTP_PROXY="${SPEL_HTTP_PROXY:-UNDEF}"

if [[ "$HTTP_PROXY" -ne "UNDEF" ]]
then
   printf "\n%s\n" "${HTTP_PROXY}" >> /etc/yum.conf
fi

# install cloud-init
yum -y install cloud-init
yum -y update
yum clean all

# configure waagent to use cloud-init
echo "Configuring waagent"
# per https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
/usr/sbin/chkconfig waagent on
## Not per above ref, added to allow cloud-init or user to manage resource disk to match Azure Marketplace Ubuntu image settings
/usr/bin/sed -i 's|ResourceDisk.Format=y|ResourceDisk.Format=n|' /etc/waagent.conf
## End Not per above ref, added to allow cloud-init or user to manage resource disk to match Azure Marketplace Ubuntu image settings
/usr/bin/sed -i 's|Provisioning.Enabled=y|Provisioning.Enabled=n|' /etc/waagent.conf
/usr/bin/sed -i 's|Provisioning.UseCloudInit=n|Provisioning.UseCloudInit=y|' /etc/waagent.conf

echo "builder-azure-image.sh complete"'!'
