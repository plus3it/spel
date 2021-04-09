#!/bin/bash
#
# Execute AMIGen7 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENBRANCH="${SPEL_AMIGENBRANCH:-master}"
AMIGENMANFST="${SPEL_AMIGENMANFST}"
AMIGENPKGGRP="${SPEL_AMIGENPKGGRP:-core}"
AMIGENSOURCE="${SPEL_AMIGENSOURCE:-https://github.com/plus3it/AMIgen7.git}"
AMIGENSTORLAY="${SPEL_AMIGENSTORLAY:-/:rootVol:4,swap:swapVol:2,/home:homeVol:1,/var:varVol:2,/var/log:logVol:2,/var/log/audit:auditVol:100%FREE}"
AMIUTILS="/tmp/ami-utils"
AMIUTILSSOURCE="${SPEL_AMIUTILSSOURCE:-https://github.com/ferricoxide/Lx-GetAMI-Utils.git}"
AWSCLIV1SOURCE="${SPEL_AWSCLIV1SOURCE:-https://s3.amazonaws.com/aws-cli/awscli-bundle.zip}"
AWSCLIV2SOURCE="${SPEL_AWSCLIV2SOURCE}"
BOOTLABEL="${SPEL_BOOTLABEL:-/boot}"
BUILDNAME="${SPEL_BUILDNAME}"
CHROOT="${SPEL_CHROOT:-/mnt/ec2-root}"
CLOUDPROVIDER="${SPEL_CLOUDPROVIDER:-aws}"
CUSTOMREPONAME="${SPEL_CUSTOMREPONAME}"
CUSTOMREPORPM="${SPEL_CUSTOMREPORPM}"
DEVNODE="${SPEL_DEVNODE:-/dev/nvme0n1}"
ELBUILD="/tmp/el-build"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm}"
EPELREPO="${SPEL_EPELREPO:-epel}"
EXTRARPMS="${SPEL_EXTRARPMS}"
FIPSDISABLE="${SPEL_FIPSDISABLE}"
PYTHON3_BIN="/usr/bin/python3.6"
PYTHON3_LINK="/usr/bin/python3"
VGNAME="${SPEL_VGNAME:-VolGroup00}"

read -r -a BUILDDEPS <<< "${SPEL_BUILDDEPS:-lvm2 parted yum-utils unzip git}"


# Make interactive-execution more-verbose unless explicitly told not to
if [[ $( tty -s ) -eq 0 ]] && [[ ${DEBUG} == "UNDEF" ]]
then
   DEBUG="true"
fi


# Error handler function
function err_exit {
   local ERRSTR
   local ISNUM
   local SCRIPTEXIT

   ERRSTR="${1}"
   ISNUM='^[0-9]+$'
   SCRIPTEXIT="${2:-1}"

   if [[ ${DEBUG} == true ]]
   then
      # Our output channels
      logger -i -t "${PROGNAME}" -p kern.crit -s -- "${ERRSTR}"
   else
      logger -i -t "${PROGNAME}" -p kern.crit -- "${ERRSTR}"
   fi

   # Only exit if requested exit is numerical
   if [[ ${SCRIPTEXIT} =~ ${ISNUM} ]]
   then
      exit "${SCRIPTEXIT}"
   fi
}



DEFAULTREPOS=(
    base
    updates
    extras
)
if [[ $(rpm --quiet -q redhat-release-server)$? -eq 0 ]]
then
    DEFAULTREPOS=(
        # RHUI 2 repo names
        rhui-REGION-client-config-server-7
        rhui-REGION-rhel-server-releases
        rhui-REGION-rhel-server-rh-common
        rhui-REGION-rhel-server-optional
        rhui-REGION-rhel-server-extras
        # RHUI 3 repo names
        rhui-client-config-server-7
        rhel-7-server-rhui-rpms
        rhel-7-server-rhui-rh-common-rpms
        rhel-7-server-rhui-optional-rpms
        rhel-7-server-rhui-extras-rpms
        # RHUI 3 repo names in EL7.7 GA
        rhui-rhel-7-server-rhui-rpms
        rhui-rhel-7-server-rhui-rh-common-rpms
        rhui-rhel-7-server-rhui-optional-rpms
        rhui-rhel-7-server-rhui-extras-rpms
    )
fi
DEFAULTREPOS+=(epel)

if [[ -z "${CUSTOMREPONAME}" ]]
then
    CUSTOMREPONAME=$(IFS=,; echo "${DEFAULTREPOS[*]}")
fi

MKFSFORCEOPT="-F"
if [[ "$BUILDNAME" =~ "xfs" ]]
then
    MKFSFORCEOPT="-f"
fi

export CHROOT FIPSDISABLE MKFSFORCEOPT

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

# Changing this to a function to better align with amigen8-build
function CollectManifest {
echo "Saving the release info to the manifest"
cat "${CHROOT}/etc/redhat-release" > /tmp/manifest.txt

if [[ "${CLOUDPROVIDER}" == "aws" ]]
then
    if [[ -n "$AWSCLIV1SOURCE" ]]
    then
        echo "Saving the aws-cli-v1 version to the manifest"
        [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
        set +x
        (chroot "${CHROOT}" /usr/local/bin/aws1 --version) 2>&1 | tee -a /tmp/manifest.txt
        eval "$XTRACE"
    fi
    if [[ -n "$AWSCLIV2SOURCE" ]]
    then
        echo "Saving the aws-cli-v2 version to the manifest"
        [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
        set +x
        (chroot "${CHROOT}" /usr/local/bin/aws2 --version) 2>&1 | tee -a /tmp/manifest.txt
        eval "$XTRACE"
    fi
elif [[ "${CLOUDPROVIDER}" == "azure" ]]
then
    echo "Saving the waagent version to the manifest"
    [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
    set +x
    (chroot "${CHROOT}" /usr/sbin/waagent --version) 2>&1 | tee -a /tmp/manifest.txt
    eval "$XTRACE"
fi

echo "Saving the RPM manifest"
rpm --root "${CHROOT}" -qa | sort -u >> /tmp/manifest.txt
}


set -x
set -e
set -o pipefail

echo "Installing build-host dependencies"
yum -y install "${BUILDDEPS[@]}"
rpm -q "${BUILDDEPS[@]}"

echo "Installing custom repo packages in the builder box"
IFS="," read -r -a BUILDER_CUSTOMREPORPM <<< "$CUSTOMREPORPM"
for RPM in "${BUILDER_CUSTOMREPORPM[@]}"
do
      { STDERR=$(yum -y install "$RPM" 2>&1 1>&$out); } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
done

echo "Enabling repos in the builder box"
yum-config-manager --disable "*" > /dev/null
yum-config-manager --enable "$CUSTOMREPONAME" > /dev/null

if [[ -n "${EPELRELEASE}" ]]
then
    { STDERR=$(yum -y install "$EPELRELEASE" 2>&1 1>&$out); } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
fi

if [[ -n "${EPELREPO}" ]]
then
    yum-config-manager --enable "$EPELREPO" > /dev/null
fi

echo "Installing specified extra packages in the builder box"
IFS="," read -r -a BUILDER_EXTRARPMS <<< "$EXTRARPMS"
for RPM in "${BUILDER_EXTRARPMS[@]}"
do
      { STDERR=$(yum -y install "$RPM" 2>&1 1>&$out); } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
done

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
git clone "${AMIUTILSSOURCE}" "${AMIUTILS}" --depth 1

for RPM in "${AMIUTILS}"/*.el7.*.rpm
do
    echo "Creating link for ${RPM} in ${ELBUILD}/AWSpkgs/"
    ln "${RPM}" "${ELBUILD}"/AWSpkgs/
done

echo "Executing DiskSetup.sh"
bash -eux -o pipefail "${ELBUILD}"/DiskSetup.sh -b "${BOOTLABEL}" -v "${VGNAME}" -d "${DEVNODE}" -p "${AMIGENSTORLAY}"

echo "Executing MkChrootTree.sh"
bash -eux -o pipefail "${ELBUILD}"/MkChrootTree.sh "${DEVNODE}" "" "${AMIGENSTORLAY}"

echo "Executing MkTabs.sh"
bash -eux -o pipefail "${ELBUILD}"/MkTabs.sh "${DEVNODE}"

# Construct the cli option string for alternate-manifest
CLIOPT_ALTMANIFEST=""
if [[ -n ${AMIGENMANFST} ]]
then
   CLIOPT_ALTMANIFEST=( -m "${AMIGENMANFST}" )
   echo "Sending manifest-option '${CLIOPT_ALTMANIFEST[*]}'"
else
   CLIOPT_ALTMANIFEST=( -g "${AMIGENPKGGRP}" )
   echo "Sending manifest-option '${CLIOPT_ALTMANIFEST[*]}'"
fi


# Construct the cli option string for extra rpms
CLIOPT_EXTRARPMS=""
if [[ -n "${EXTRARPMS}" ]]
then
    CLIOPT_EXTRARPMS=(-e "${EXTRARPMS}")
fi

# Construct the cli option string for a custom repo
CLIOPT_CUSTOMREPO=""
if [[ -n "${CUSTOMREPORPM}" && -n "${CUSTOMREPONAME}" ]]
then
    CLIOPT_CUSTOMREPO=(-r "${CUSTOMREPORPM}" -b "${CUSTOMREPONAME}")
fi

echo "Executing ChrootBuild.sh"
bash -eux -o pipefail "${ELBUILD}"/ChrootBuild.sh "${CLIOPT_CUSTOMREPO[@]}" "${CLIOPT_EXTRARPMS[@]}" "${CLIOPT_ALTMANIFEST[@]}"

if [[ "${CLOUDPROVIDER}" == "aws" ]]
then
    # Construct the cli option string for aws utils
    CLIOPT_AWSUTILS=("-m ${CHROOT}" "-d ${ELBUILD}/AWSpkgs")

    # Whether to install AWS CLIv1
    if [[ -n "${AWSCLIV1SOURCE}" ]]
    then
      CLIOPT_AWSUTILS+=("-C ${AWSCLIV1SOURCE}")
    fi

    # Whether to install AWS CLIv2
    if [[ -n "${AWSCLIV2SOURCE}" ]]
    then
      CLIOPT_AWSUTILS+=("-c ${AWSCLIV2SOURCE}")
    fi

    # Epel mirrors are maddening; retry 5 times to work around issues
    echo "Executing AWSutils.sh"
    retry 5 bash -eux -o pipefail "${ELBUILD}/AWSutils.sh ${CLIOPT_AWSUTILS[*]}"
fi

echo "Executing ChrootCfg.sh"
bash -eux -o pipefail "${ELBUILD}"/ChrootCfg.sh


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
bash -eux -o pipefail "${ELBUILD}"/GrubSetup.sh "${DEVNODE}"

echo "Executing NetSet.sh"
bash -eux -o pipefail "${ELBUILD}"/NetSet.sh

echo "Executing CleanChroot.sh"
bash -eux -o pipefail "${ELBUILD}"/CleanChroot.sh

echo "Executing PreRelabel.sh"
bash -eux -o pipefail "${ELBUILD}"/PreRelabel.sh

if [[ -x "${CHROOT}${PYTHON3_BIN}" && ! -s "${CHROOT}${PYTHON3_LINK}" ]]
then
    echo "Ensuring python3 symlink exists"
    chroot "$CHROOT" ln -sf "$PYTHON3_BIN" "$PYTHON3_LINK"
fi

if [[ "${CLOUDPROVIDER}" == "azure" ]]
then
    echo "Configuring waagent"
    #per https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
    chroot "${CHROOT}" /usr/sbin/chkconfig waagent on
    chroot "${CHROOT}" /usr/bin/sed -i 's|USERCTL="yes"|USERCTL="no"|' /etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'NM_CONTROLLED="no"' >> "${CHROOT}"/etc/sysconfig/network-scripts/ifcfg-eth0
    chroot "${CHROOT}" /usr/bin/sed -i 's|DHCP_HOSTNAME=localhost.localdomain||' /etc/sysconfig/network-scripts/ifcfg-eth0
    ### Allow cloud-init or user to manage resource disk, matches Azure Marketplace Ubuntu image settings
    chroot "${CHROOT}" /usr/bin/sed -i 's|ResourceDisk.Format=y|ResourceDisk.Format=n|' /etc/waagent.conf
    ###
    chroot "${CHROOT}" /usr/bin/sed -i 's|Provisioning.Enabled=y|Provisioning.Enabled=n|' /etc/waagent.conf
    chroot "${CHROOT}" /usr/bin/sed -i 's|Provisioning.UseCloudInit=n|Provisioning.UseCloudInit=y|' /etc/waagent.conf
    chroot "${CHROOT}" /usr/sbin/waagent -force -deprovision
fi

# Calling new CollectManifest function
CollectManifest

echo "Executing Umount.sh"
bash -eux -o pipefail "${ELBUILD}"/Umount.sh

echo "amigen7-build.sh complete"'!'
