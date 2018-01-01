#!/bin/bash
#
# Execute AMIGen7 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
AMIGENSOURCE="${SPEL_AMIGENSOURCE:-https://github.com/plus3it/AMIgen7.git}"
AMIUTILSSOURCE="${SPEL_AMIUTILSSOURCE:-https://github.com/ferricoxide/Lx-GetAMI-Utils.git}"
AWSCLISOURCE="${SPEL_AWSCLISOURCE:-https://s3.amazonaws.com/aws-cli}"
BOOTLABEL="${SPEL_BOOTLABEL:-/boot}"
BUILDDEPS="${SPEL_BUILDDEPS:-lvm2 parted yum-utils unzip git}"
CHROOT="${SPEL_CHROOT:-/mnt/ec2-root}"
CLOUDPROVIDER="${SPEL_CLOUDPROVIDER:-aws}"
CUSTOMREPORPM="${SPEL_CUSTOMREPORPM}"
CUSTOMREPONAME="${SPEL_CUSTOMREPONAME}"
DEVNODE="${SPEL_DEVNODE:-/dev/xvda}"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm}"
EPELREPO="${SPEL_EPELREPO:-epel}"
EXTRARPMS="${SPEL_EXTRARPMS}"
FIPSDISABLE="${SPEL_FIPSDISABLE}"
VGNAME="${SPEL_VGNAME:-VolGroup00}"

ELBUILD="/tmp/el-build"
AMIUTILS="/tmp/ami-utils"

DEFAULTREPOS=(
    base
    updates
    extras
    epel
)
if [[ $(rpm --quiet -q redhat-release-server)$? -eq 0 ]]
then
    DEFAULTREPOS=(
        rhui-REGION-client-config-server-7
        rhui-REGION-rhel-server-releases
        rhui-REGION-rhel-server-rh-common
        rhui-REGION-rhel-server-optional
        rhui-REGION-rhel-server-extras
        epel
    )
fi

export CHROOT
export FIPSDISABLE

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
        test $result -eq 0 && break || {
            ((n++))
            echo "Attempt $n, command failed :: $cmd"
        }
    done

    if [[ "${ERREXIT}" == "1" ]]
    then
        set -e
    fi

    return $result
}  # ----------  end of function retry  ----------

disable_strict_host_check()
{
    # Take a git ssh connection string of the form:
    #    user@host:account/project.git
    # determine the `host`, and add an entry to ~/.ssh/config to disable the
    # strict host check

    local conn=$1
    [[ $# -lt 1 ]] && {
        echo "Usage $0 <git_connection_string>"
        return 1
    }

    local host
    host=$( echo "${conn}" | awk -F":" '{print $1}' )

    if [[ "${host}" == *"@"* ]]
    then
        host=$( echo "${host}" | awk -F"@" '{print $2}' )
    fi

    touch ~/.ssh/config
    if [[ $(grep -q "${host}" ~/.ssh/config)$? -ne 0 ]]
    then
        echo -e "Host $host\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
        chmod 600 ~/.ssh/config
    fi
}  # ----------  end of function add_ssh_host  ----------

set -x
set -e

echo "Installing build-host dependencies"
yum -y install ${BUILDDEPS}

if [[ "${AMIGENSOURCE}" == *"@"* ]]
then
    echo "Adding known host for AMIGen source"
    disable_strict_host_check "${AMIGENSOURCE}"
fi

if [[ "${AMIUTILSSOURCE}" == *"@"* ]]
then
    echo "Adding known host for AMIUtils source"
    disable_strict_host_check "${AMIUTILSSOURCE}"
fi

echo "Cloning source of the AMIGen project"
git clone "${AMIGENSOURCE}" "${ELBUILD}"
chmod +x "${ELBUILD}"/*.sh

echo "Cloning source of the AMI utils project"
git clone "${AMIUTILSSOURCE}" "${AMIUTILS}" --depth 1

for RPM in "${AMIUTILS}"/*.el7.noarch.rpm
do
    echo "Creating link for ${RPM} in ${ELBUILD}/AWSpkgs/"
    ln "${RPM}" "${ELBUILD}"/AWSpkgs/
done

echo "Executing DiskSetup.sh"
bash -x "${ELBUILD}"/DiskSetup.sh -b "${BOOTLABEL}" -v "${VGNAME}" -d "${DEVNODE}"

echo "Executing MkChrootTree.sh"
bash -x "${ELBUILD}"/MkChrootTree.sh "${DEVNODE}"

echo "Executing MkTabs.sh"
bash -x "${ELBUILD}"/MkTabs.sh "${DEVNODE}"

# Construct the cli option string for extra rpms
CLIOPT_EXTRARPMS=""
if [[ -n "${EXTRARPMS}" ]]
then
    CLIOPT_EXTRARPMS=(-e "${EXTRARPMS}")
fi

# Construct the cli option string for a custom repo
CLIOPT_CUSTOMREPO=""
if [[ -z "${CUSTOMREPONAME}" ]]
then
    CUSTOMREPONAME=$(IFS=,; echo "${DEFAULTREPOS[*]}")
fi

if [[ -n "${CUSTOMREPORPM}" && -n "${CUSTOMREPONAME}" ]]
then
    CLIOPT_CUSTOMREPO=(-r "${CUSTOMREPORPM}" -b "${CUSTOMREPONAME}")
fi

echo "Executing ChrootBuild.sh"
bash -x "${ELBUILD}"/ChrootBuild.sh "${CLIOPT_CUSTOMREPO[@]}" "${CLIOPT_EXTRARPMS[@]}"

if [[ "${CLOUDPROVIDER}" == "aws" ]]
then
    # Epel mirrors are maddening; retry 5 times to work around issues
    echo "Executing AWScliSetup.sh"
    retry 5 bash -x "${ELBUILD}"/AWScliSetup.sh "${AWSCLISOURCE}" "${EPELRELEASE}" "${EPELREPO}"
fi

echo "Executing ChrootCfg.sh"
bash -x "${ELBUILD}"/ChrootCfg.sh

echo "Executing GrubSetup.sh"
if [[ "${CLOUDPROVIDER}" == "azure" ]]
then
    #adding Azure grub defaults per https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
    /usr/bin/sed -i \
        -e 's|crashkernel=auto|rootdelay=300|' \
        -e 's|vconsole.keymap=us|console=ttyS0|' \
        -e 's|vconsole.font=latarcyrheb-sun16 console=tty0|earlyprintk=ttyS0|' \
        -e '\|printf "console=ttyS0,115200n8 "|d' \
        "${ELBUILD}"/GrubSetup.sh
    ##end adding Azure grub defaults
fi
bash -x "${ELBUILD}"/GrubSetup.sh "${DEVNODE}"

echo "Executing NetSet.sh"
bash -x "${ELBUILD}"/NetSet.sh

echo "Executing CleanChroot.sh"
bash -x "${ELBUILD}"/CleanChroot.sh

echo "Executing PreRelabel.sh"
bash -x "${ELBUILD}"/PreRelabel.sh

if [[ "${CLOUDPROVIDER}" == "azure" ]]
then
    echo "Configuring waagent"
    #per https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
    chroot "${CHROOT}" /usr/sbin/chkconfig waagent on
    chroot "${CHROOT}" /usr/bin/sed -i 's|USERCTL="yes"|USERCTL="no"|' /etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'NM_CONTROLLED="no"' >> "${CHROOT}"/etc/sysconfig/network-scripts/ifcfg-eth0
    chroot "${CHROOT}" /usr/bin/sed -i 's|DHCP_HOSTNAME=localhost.localdomain||' /etc/sysconfig/network-scripts/ifcfg-eth0
    ## Not per above ref, added to allow cloud-init or user to manage resource disk to match Azure Marketplace Ubuntu image settings
    chroot "${CHROOT}" /usr/bin/sed -i 's|ResourceDisk.Format=y|ResourceDisk.Format=n|' /etc/waagent.conf
    ## End Not per above ref, added to allow cloud-init or user to manage resource disk to match Azure Marketplace Ubuntu image settings
    chroot "${CHROOT}" /usr/bin/sed -i 's|Provisioning.Enabled=y|Provisioning.Enabled=n|' /etc/waagent.conf
    chroot "${CHROOT}" /usr/bin/sed -i 's|Provisioning.UseCloudInit=n|Provisioning.UseCloudInit=y|' /etc/waagent.conf
    chroot "${CHROOT}" /usr/sbin/waagent -force -deprovision
fi

if [[ "${CLOUDPROVIDER}" == "aws" ]]
then
    echo "Saving the aws cli version to the manifest"
    (chroot "${CHROOT}" /usr/bin/aws --version) > /tmp/manifest.log 2>&1
elif [[ "${CLOUDPROVIDER}" == "azure" ]]
then
    echo "Saving the waagent version to the manifest"
    (chroot "${CHROOT}" /usr/sbin/waagent --version) > /tmp/manifest.log 2>&1
fi

echo "Saving the RPM manifest"
rpm --root "${CHROOT}" -qa | sort -u >> /tmp/manifest.log

echo "Executing Umount.sh"
bash -x "${ELBUILD}"/Umount.sh

echo "amigen7-build.sh complete"'!'
