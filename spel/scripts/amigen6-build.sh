#!/bin/bash
#
# Execute AMIGen6 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
AMIGENSOURCE="${SPEL_AMIGENSOURCE:-https://github.com/plus3it/AMIgen6.git}"
AMIGENBRANCH="${SPEL_AMIGENBRANCH:-master}"
AMIUTILSSOURCE="${SPEL_AMIUTILSSOURCE:-https://github.com/ferricoxide/Lx-GetAMI-Utils.git}"
AWSCLISOURCE="${SPEL_AWSCLISOURCE:-https://s3.amazonaws.com/aws-cli/awscli-bundle.zip}"
BOOTLABEL="${SPEL_BOOTLABEL:-/boot}"
BUILDDEPS=(${SPEL_BUILDDEPS:-lvm2 parted yum-utils unzip git})
CHROOT="${SPEL_CHROOT:-/mnt/ec2-root}"
CUSTOMREPORPM="${SPEL_CUSTOMREPORPM}"
CUSTOMREPONAME="${SPEL_CUSTOMREPONAME}"
DEVNODE="${SPEL_DEVNODE:-/dev/xvda}"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm}"
EPELREPO="${SPEL_EPELREPO:-epel}"
EXTRARPMS="${SPEL_EXTRARPMS}"
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
        rhui-REGION-client-config-server-6
        rhui-REGION-rhel-server-releases
        rhui-REGION-rhel-server-rh-common
        epel
    )
fi


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
yum -y install "${BUILDDEPS[@]}"

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
git clone --branch "${AMIGENBRANCH}" "${AMIGENSOURCE}" "${ELBUILD}"
chmod +x "${ELBUILD}"/*.sh

echo "Cloning source of the AMI utils project"
git clone "${AMIUTILSSOURCE}" "${AMIUTILS}"

for RPM in "${AMIUTILS}"/*.el6.noarch.rpm
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

# Epel mirrors are maddening; retry 5 times to work around issues
echo "Executing AWScliSetup.sh"
retry 5 bash "${ELBUILD}"/AWScliSetup.sh "${AWSCLISOURCE}" "${EPELRELEASE}"

echo "Executing GrowSetup.sh"
retry 5 bash "${ELBUILD}"/GrowSetup.sh "${EPELREPO}"

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

echo "Saving the aws cli version to the manifest"
(chroot "${CHROOT}" /usr/bin/aws --version) > /tmp/manifest.txt 2>&1

echo "Saving the RPM manifest"
rpm --root "${CHROOT}" -qa | sort -u >> /tmp/manifest.txt

echo "Executing UmountChroot.sh"
bash "${ELBUILD}"/UmountChroot.sh

echo "amigen6-build.sh complete"'!'
