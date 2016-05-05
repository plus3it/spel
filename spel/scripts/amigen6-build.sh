#!/bin/bash
#
# Execute AMIGen6 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
AMIGENSOURCE="${SPEL_AMIGENSOURCE:-https://github.com/ferricoxide/AMIgen6.git}"
AMIUTILSSOURCE="${SPEL_AMIUTILSSOURCE:-https://github.com/ferricoxide/Lx-GetAMI-Utils.git}"
AWSCLISOURCE="${SPEL_AWSCLISOURCE:-https://s3.amazonaws.com/aws-cli}"
BOOTLABEL="${SPEL_BOOTLABEL:-/boot}"
BUILDDEPS="${SPEL_BUILDDEPS:-lvm2 parted yum-utils unzip git}"
CHROOT="${SPEL_CHROOT:-/mnt/ec2-root}"
DEVNODE="${SPEL_DEVNODE:-/dev/xvda}"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm}"
VGNAME="${SPEL_VGNAME:-VolGroup00}"

ELBUILD="/tmp/el-build"
AMIUTILS="/tmp/ami-utils"

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

add_known_host()
{
    # Take a git ssh connection string of the form:
    #    user@host:account/project.git
    # determine the `host`, use ssh-keyscan to get its ssh key, and
    # add the key to ~/.ssh/known_hosts

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

    # Get the key
    local key
    key=$(ssh-keyscan "${host}")

    # Add the key to known_hosts
    if [[ -n "${key}" ]]
    then
        touch ~/.ssh/known_hosts
        if [[ $(grep -q "${key}" ~/.ssh/known_hosts)$? -ne 0 ]]
        then
            echo "${key}" >> ~/.ssh/known_hosts
        fi
    fi
}  # ----------  end of function add_ssh_host  ----------

set -x
set -e

echo "Installing build-host dependencies"
yum -y install ${BUILDDEPS}

if [[ "${AMIGENSOURCE}" == *":"* ]]
then
    echo "Adding known host for AMIGen source"
    add_known_host "${AMIGENSOURCE}"
fi

if [[ "${AMIUTILSSOURCE}" == *":"* ]]
then
    echo "Adding known host for AMIUtils source"
    add_known_host "${AMIUTILSSOURCE}"
fi

echo "Cloning source of the AMIGen project"
git clone "${AMIGENSOURCE}" "${ELBUILD}"
chmod +x "${ELBUILD}"/*.sh

echo "Cloning source of the AMI utils project"
git clone "${AMIUTILSSOURCE}" "${AMIUTILS}"

for RPM in $(grep -v el7 "${AMIUTILS}"/*.noarch.rpm)
do
    echo "Creating link for ${RPM} in ${ELBUILD}/AWSpkgs/"
    ln "${RPM}" "${ELBUILD}"/AWSpkgs/
done

echo "Executing CarveEBS.sh"
bash "${ELBUILD}"/CarveEBS.sh -b "${BOOTLABEL}" -v "${VGNAME}" -d "${DEVNODE}"

echo "Executing MkChrootTree.sh"
bash "${ELBUILD}"/MkChrootTree.sh "${DEVNODE}"

echo "Executing MkTabs.sh"
bash "${ELBUILD}"/MkTabs.sh

echo "Executing ChrootBuild.sh"
bash "${ELBUILD}"/ChrootBuild.sh

# Epel mirrors are maddening; retry 5 times to work around issues
echo "Executing AWScliSetup.sh"
retry 5 bash "${ELBUILD}"/AWScliSetup.sh "${AWSCLISOURCE}" "${EPELRELEASE}"

echo "Executing ChrootCfg.sh"
bash "${ELBUILD}"/ChrootCfg.sh

echo "Executing MkCfgFiles.sh"
bash "${ELBUILD}"/MkCfgFiles.sh

echo "Executing CleanChroot.sh"
bash "${ELBUILD}"/CleanChroot.sh

echo "Executing HVMprep.sh"
bash "${ELBUILD}"/HVMprep.sh "${DEVNODE}"

echo "Executing PreRelabel.sh"
bash "${ELBUILD}"/PreRelabel.sh

echo "Saving the RPM manifest"
rpm --root "${CHROOT}" -qa | sort -u > /tmp/manifest.log

echo "Executing UmountChroot.sh"
bash "${ELBUILD}"/UmountChroot.sh

echo "amigen6-build.sh complete"'!'
