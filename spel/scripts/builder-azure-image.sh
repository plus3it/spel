#!/bin/bash
#
# Script to create a custom image from which to later create a spel image.
# This script expects an Azure marketplace EL7 offer, publisher, sku that does
# not have cloud-init configured.  The script will install and configure
# cloud-init in the resultant custom image which is to be used in subsequent
# execution for spel image creation.
#
##############################################################################
read -r -a BUILDDEPS <<< "${SPEL_BUILDDEPS:-lvm2 parted yum-utils unzip git}"
AMIGENHTTPPROXY="${SPEL_HTTP_PROXY:-}"

retry()
{
    # Make an arbitrary number of attempts to execute an arbitrary command,
    # passing it arbitrary parameters. Convenient for working around
    # intermittent errors (which occur often with poor repo mirrors).
    #
    # Returns the exit code of the command.
    local n=0
    local try=$1
    local cmd="${*: 2}"
    local result=1
    [[ $# -le 1 ]] && {
        echo "Usage $0 <number_of_retry_attempts> <Command>"
        exit $result
    }

    echo "Will try $try time(s) :: $cmd"

    if [[ "${SHELLOPTS}" == *":errexit:"* ]]
    then
        set +e
        local ERREXIT=1
    fi

    until [[ $n -ge $try ]]
    do
        sleep $n
        $cmd
        result=$?
        if [[ $result -eq 0 ]]
        then
            break
        else
            ((n++))
            echo "Attempt $n, command failed :: $cmd"
        fi
    done

    if [[ "${ERREXIT}" == "1" ]]
    then
        set -e
    fi

    return $result
}  # ----------  end of function retry  ----------

set -x
set -e

if [[ $(rpm --quiet -q centos-release)$? -eq 0 ]]
then
   printf "%s\n" "${AMIGENHTTPPROXY}" >> /etc/yum.conf
fi

# raw rhel image has old refs to extinct rhui (https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/redhat/redhat-rhui#troubleshoot-connection-problems-to-azure-rhui)
# cat /etc/yum.repos.d/rh-cloud.repo
# update repo file (wasn't working previously; likely rhui update issues or nsg issues)
# sudo yum update -y --disablerepo='*' --enablerepo='*microsoft*'
echo "Installing build-host dependencies"
yum -y install "${BUILDDEPS[@]}"

#install cloud-init
yum -y install cloud-init
yum -y update
yum clean all

#configure /etc/cloud/cloud.cfg
/usr/bin/sed -i \
   -e 's|ssh_pwauth:   0|ssh_pwauth:   1|' \
   -e 's|    name: centos|    name: maintuser|' \
   -e 's|    gecos: Cloud User|    gecos: Local Maintenance User|' \
   -e 's|    groups: [wheel, adm, systemd-journal]|    groups: [wheel, adm]|' \
   -e 's|    sudo: ["ALL=(ALL) NOPASSWD:ALL"]|    sudo: ["ALL=(root) NOPASSWD:ALL"]|' \
   /etc/cloud/cloud.cfg

#configure waagent to use cloud-init
echo "Configuring waagent"
#per https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
/usr/sbin/chkconfig waagent on
## Not per above ref, added to allow cloud-init or user to manage resource disk to match Azure Marketplace Ubuntu image settings
/usr/bin/sed -i 's|ResourceDisk.Format=y|ResourceDisk.Format=n|' /etc/waagent.conf
## End Not per above ref, added to allow cloud-init or user to manage resource disk to match Azure Marketplace Ubuntu image settings
/usr/bin/sed -i 's|Provisioning.Enabled=y|Provisioning.Enabled=n|' /etc/waagent.conf
/usr/bin/sed -i 's|Provisioning.UseCloudInit=n|Provisioning.UseCloudInit=y|' /etc/waagent.conf

echo "Saving the release info to the manifest"
cat /etc/redhat-release > /tmp/manifest.txt

echo "Saving the waagent version to the manifest"
[[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
set +x
(/usr/sbin/waagent --version) >> /tmp/manifest.txt 2>&1
eval "$XTRACE"

echo "Saving the RPM manifest"
rpm -qa | sort -u >> /tmp/manifest.txt


echo "builder-azure-image.sh complete"'!'
