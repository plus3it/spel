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
DEPLOYKEY="${SPEL_DEPLOYKEY}"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm}"
VGNAME="${SPEL_VGNAME:-VolGroup00}"

ELBUILD="/tmp/el-build"
AMIUTILS="/tmp/ami-utils"
SSHIDFILE=""

retry()
{
    # Make an arbitrary number of attempts to execute an arbitrary command,
    # passing it arbitrary parameters. Convenient for working around
    # intermittent errors (which occur often with poor repo mirrors).
    #
    # Returns the exit code of the command.
    local n=0
    local try=$1
    local cmd="${@: 2}"
    local result=1
    [[ $# -le 1 ]] && {
        echo "Usage $0 <number_of_retry_attempts> <Command>"
        exit $result
    }

    echo "Will try $try time(s) :: $cmd"

    set +e
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
    set -e
    return $result
}  # ----------  end of function retry  ----------

add_ssh_host()
{
    # Take a git ssh connection string of the form:
    #    user@host:account/project.git
    # and an optional path to a private key, id_file, and add an entry to
    # ~/.ssh/config:
    #    host project
    #      HostName host
    #      IdentityFile id_file
    #      User user
    #
    # Return a new connection string of the form:
    #    user@project:account/project.git

    local conn=$1
    local id_file=$2
    [[ $# -lt 1 ]] && {
        echo "Usage $0 <git_connection_string> <ssh_identity_file>"
        return 1
    }

    local host=$( echo "${conn}" | awk -F":" '{print $1}' )
    local project=$( echo "${conn}" | awk -F":" '{print $2}')
    local conf_host=$( echo "${project}" | awk -F"/" '{print $2}' | \
        awk -F"." '{print $1}' )

    if [[ "${host}" == *"@"* ]]
    then
        local user=$( echo "${host}" | awk -F"@" '{print $1}' )
        local host=$( echo "${host}" | awk -F"@" '{print $2}' )
    fi

    # Trust the host
    ssh-keyscan "${host}" >> ~/.ssh/known_hosts

    # Check for an existing ssh host config and delete it
    if [[ -e ~/.ssh/config ]]
    then
        sed -i "{
            /^host ${conf_host}$/I,/^host/I{//!d}
            /^host ${conf_host}$/Id
        }" ~/.ssh/config
    fi

    # Add the ssh host config
    (
        printf "host %s\n" "${conf_host}"
        printf "  HostName %s\n" "${host}"
        if [[ -n "${id_file}" ]]
        then
            printf "  IdentityFile %s\n" "${id_file}"
        fi
        if [[ -n "${user}" ]]
        then
            printf "  User %s\n" "${user}"
        fi
    ) >> ~/.ssh/config

    if [[ -n "${user}" ]]
    then
        echo "${user}@${conf_host}:${project}"
    else
        echo "${conf_host}:${project}"
    fi
}  # ----------  end of function add_ssh_host  ----------

set -x
set -e

echo "Installing build-host dependencies"
yum -y install ${BUILDDEPS}

if [[ -n "${DEPLOYKEY}" ]]
then
    echo "Setting up the deploy key"
    SSHIDFILE="~/.ssh/spel"
    rm -f "${SSHIDFILE}"
    curl -sSkL -o "${SSHIDFILE}" "${DEPLOYKEY}"
    chmod 600 "${SSHIDFILE}"
fi

if [[ "${AMIGENSOURCE}" == *":"* ]]
then
    echo "Adding ssh config for AMIgen source"
    AMIGENSOURCE=$(add_ssh_host "${AMIGENSOURCE}" "${SSHIDFILE}")
fi

if [[ "${AMIUTILSSOURCE}" == *":"* ]]
then
    echo "Adding ssh config for AMIutils source"
    AMIUTILSSOURCE=$(add_ssh_host "${AMIUTILSSOURCE}" "${SSHIDFILE}")
fi

echo "Cloning source of the AMIGen project"
git clone "${AMIGENSOURCE}" "${ELBUILD}"
chmod +x "${ELBUILD}"/*.sh

echo "Cloning source of the AMI utils project"
git clone "${AMIUTILSSOURCE}" "${AMIUTILS}"

for RPM in $(ls "${AMIUTILS}"/*.noarch.rpm | grep -v el7)
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
