#!/bin/bash
#
# Execute AMIGen7 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENBOOTSIZE="${SPEL_AMIGENBOOTSIZE:-500m}"
AMIGENBRANCH="${SPEL_AMIGENBRANCH:-master}"
AMIGENBUILDDEV="${SPEL_AMIGENBUILDDEV:-/dev/nvme0n1}"
AMIGENCHROOT="${SPEL_AMIGENCHROOT:-/mnt/ec2-root}"
AMIGENFSTYPE="${SPEL_AMIGENFSTYPE:-ext4}"
AMIGENMANFST="${SPEL_AMIGENMANFST}"
AMIGENPKGGRP="${SPEL_AMIGENPKGGRP:-core}"
AMIGENREPOS="${SPEL_AMIGENREPOS}"
AMIGENREPOSRC="${SPEL_AMIGENREPOSRC}"
AMIGENROOTNM="${SPEL_AMIGENROOTNM:-UNDEF}"
AMIGENSOURCE="${SPEL_AMIGENSOURCE:-https://github.com/plus3it/AMIgen7.git}"
AMIGENSTORLAY="${SPEL_AMIGENSTORLAY:-/:rootVol:4,swap:swapVol:2,/home:homeVol:1,/var:varVol:2,/var/log:logVol:2,/var/log/audit:auditVol:100%FREE}"
AMIGENVGNAME="${SPEL_AMIGENVGNAME:-VolGroup00}"
AMIUTILSSOURCE="${SPEL_AMIUTILSSOURCE:-https://github.com/ferricoxide/Lx-GetAMI-Utils.git}"
AWSCLIV1SOURCE="${SPEL_AWSCLIV1SOURCE:-https://s3.amazonaws.com/aws-cli/awscli-bundle.zip}"
AWSCLIV2SOURCE="${SPEL_AWSCLIV2SOURCE}"
BOOTLABEL="${SPEL_BOOTLABEL:-/boot}"
BUILDNAME="${SPEL_BUILDNAME}"
CLOUDPROVIDER="${SPEL_CLOUDPROVIDER:-aws}"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm}"
EPELREPO="${SPEL_EPELREPO:-epel}"
EXTRARPMS="${SPEL_EXTRARPMS}"
FIPSDISABLE="${SPEL_FIPSDISABLE}"


read -r -a BUILDDEPS <<< "${SPEL_BUILDDEPS:-lvm2 parted yum-utils unzip git}"

AMIUTILS="/tmp/ami-utils"
ELBUILD="/tmp/el-build"
PYTHON3_BIN="/usr/bin/python3.6"
PYTHON3_LINK="/usr/bin/python3"

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

if [[ -z "${AMIGENREPOS}" ]]
then
    AMIGENREPOS=$(IFS=,; echo "${DEFAULTREPOS[*]}")
fi

MKFSFORCEOPT="-F"
if [[ "$BUILDNAME" =~ "xfs" ]]
then
    MKFSFORCEOPT="-f"
fi

export AMIGENCHROOT FIPSDISABLE MKFSFORCEOPT

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

function DisableStrictHostCheck
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
    cat "${AMIGENCHROOT}/etc/redhat-release" > /tmp/manifest.txt

    if [[ "${CLOUDPROVIDER}" == "aws" ]]
    then
        if [[ -n "$AWSCLIV1SOURCE" ]]
        then
            echo "Saving the aws-cli-v1 version to the manifest"
            [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
            set +x
            (chroot "${AMIGENCHROOT}" /usr/local/bin/aws1 --version) 2>&1 | tee -a /tmp/manifest.txt
            eval "$XTRACE"
        fi
        if [[ -n "$AWSCLIV2SOURCE" ]]
        then
            echo "Saving the aws-cli-v2 version to the manifest"
            [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
            set +x
            (chroot "${AMIGENCHROOT}" /usr/local/bin/aws2 --version) 2>&1 | tee -a /tmp/manifest.txt
            eval "$XTRACE"
        fi
    elif [[ "${CLOUDPROVIDER}" == "azure" ]]
    then
        echo "Saving the waagent version to the manifest"
        [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
        set +x
        (chroot "${AMIGENCHROOT}" /usr/sbin/waagent --version) 2>&1 | tee -a /tmp/manifest.txt
        eval "$XTRACE"
    fi

    echo "Saving the RPM manifest"
    rpm --root "${AMIGENCHROOT}" -qa | sort -u >> /tmp/manifest.txt
}

function ComposeAWSutilsString {
    # Construct the cli option string for aws utils
    CLIOPT_AWSUTILS=("-m ${AMIGENCHROOT}" "-d ${ELBUILD}/AWSpkgs")

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
}

function ComposeChrootCliString {
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
    if [[ -n "${AMIGENREPOSRC}" && -n "${AMIGENREPOS}" ]]
    then
        CLIOPT_CUSTOMREPO=(-r "${AMIGENREPOSRC}" -b "${AMIGENREPOS}")
    fi
}

declare -a DISKSETUPARGS
## # Pick options for disk-setup command
function ComposeDiskSetupString {

   # Set the offset for the OS partition
   if [[ ${AMIGENBOOTSIZE} == "UNDEF" ]]
   then
      err_exit "Using minimal offset [17m] for root volumes" NONE
      DISKSETUPARGS+=("-B 17m ")
   else
      DISKSETUPARGS+=("-B" "${AMIGENBOOTSIZE}")
   fi

   # Set the bootlabel for the OS partition
   if [[ ${BOOTLABEL} == "UNDEF" ]]
   then
      err_exit "boot label needs to be defined" NONE
   else
      DISKSETUPARGS+=("-b" "${BOOTLABEL}")
   fi

   # Set the filesystem-type to use for OS filesystems
   if [[ ${AMIGENFSTYPE} == "ext4" ]]
   then
      err_exit "Using default fstype [ext4] for boot filesysems" NONE
   fi
   DISKSETUPARGS+=("-f" "${AMIGENFSTYPE}")

   # Set requested custom storage layout as necessary
   if [[ ${AMIGENSTORLAY} == "UNDEF" ]]
   then
      err_exit "Using script-default for boot-volume layout" NONE
   else
      DISKSETUPARGS+=("-p" "${AMIGENSTORLAY}")
   fi

   # Set LVM2 or bare disk-formatting
   if [[ ${AMIGENVGNAME} != "UNDEF" ]]
   then
      DISKSETUPARGS+=("-v" "${AMIGENVGNAME}")
   elif [[ ${AMIGENROOTNM} != "UNDEF" ]]
   then
      DISKSETUPARGS+=("-r" "${AMIGENROOTNM}")
   fi

   # Set device to carve
   if [[ ${AMIGENBUILDDEV} == "UNDEF" ]]
   then
      err_exit "Failed to define device to partition"
   else
      DISKSETUPARGS+=("-d" "${AMIGENBUILDDEV}")
   fi
}


set -x
set -e
set -o pipefail

# Install supplementary tooling
if [[ ${#BUILDDEPS[@]} -gt 0 ]]
then
   err_exit "Installing build-host dependencies" NONE
   yum -y install "${BUILDDEPS[@]}" || \
     err_exit "Failed installing build-host dependencies"

   err_exit "Verifying build-host dependencies" NONE
   rpm -q "${BUILDDEPS[@]}" || \
     err_exit "Verification failed"
fi

echo "Installing custom repo packages in the builder box"
IFS="," read -r -a BUILDER_AMIGENREPOSRC <<< "$AMIGENREPOSRC"
for RPM in "${BUILDER_AMIGENREPOSRC[@]}"
do
      { STDERR=$(yum -y install "$RPM" 2>&1 1>&$out); } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
done

echo "Enabling repos in the builder box"
yum-config-manager --disable "*" > /dev/null
yum-config-manager --enable "$AMIGENREPOS" > /dev/null

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

# Disable strict host-key checking when doing git-over-ssh
if [[ "${AMIGENSOURCE}" == *"@"* ]]
then
    echo "Adding known host for AMIGen source"
    DisableStrictHostCheck "${AMIGENSOURCE}"
fi

# Disable strict host-key checking when doing git-over-ssh
if [[ "${AMIUTILSSOURCE}" == *"@"* ]]
then
    echo "Adding known host for AMIUtils source"
    DisableStrictHostCheck "${AMIUTILSSOURCE}"
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

# Invoke disk-partitioner
ComposeDiskSetupString
bash -euxo pipefail "${ELBUILD}/DiskSetup.sh" "${DISKSETUPARGS[@]}" || \
    err_exit "Failure encountered with DiskSetup.sh"

echo "Executing MkChrootTree.sh"
bash -eux -o pipefail "${ELBUILD}"/MkChrootTree.sh "${AMIGENBUILDDEV}" "" -p "${AMIGENSTORLAY}" || \
    err_exit "Failure encountered with MkChrootTree.sh"

echo "Executing MkTabs.sh"
bash -eux -o pipefail "${ELBUILD}"/MkTabs.sh "${AMIGENBUILDDEV}" || \
    err_exit "Failure encountered with MkTabs.sh"

ComposeChrootCliString
echo "Executing ChrootBuild.sh"
bash -eux -o pipefail "${ELBUILD}"/ChrootBuild.sh "${CLIOPT_CUSTOMREPO[@]}" "${CLIOPT_EXTRARPMS[@]}" "${CLIOPT_ALTMANIFEST[@]}"

# Run AWSutils.sh
if [[ "${CLOUDPROVIDER}" == "aws" ]]
then
    ComposeAWSutilsString
    # Epel mirrors are maddening; retry 5 times to work around issues
    echo "Executing AWSutils.sh"
    retry 5 bash -eux -o pipefail "${ELBUILD}/AWSutils.sh ${CLIOPT_AWSUTILS[*]}"
fi

echo "Executing ChrootCfg.sh"
bash -eux -o pipefail "${ELBUILD}"/ChrootCfg.sh || \
    err_exit "Failure encountered with ChrootCfg.sh"


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
bash -eux -o pipefail "${ELBUILD}"/GrubSetup.sh "${AMIGENBUILDDEV}" || \
    err_exit "Failure encountered with GrubSetup.sh"

echo "Executing NetSet.sh"
bash -eux -o pipefail "${ELBUILD}"/NetSet.sh || \
    err_exit "Failure encountered with NetSet.sh"

echo "Executing CleanChroot.sh"
bash -eux -o pipefail "${ELBUILD}"/CleanChroot.sh || \
    err_exit "Failure encountered with CleanChroot.sh"

echo "Executing PreRelabel.sh"
bash -eux -o pipefail "${ELBUILD}"/PreRelabel.sh || \
    err_exit "Failure encountered with PreRelabel.sh"

if [[ -x "${AMIGENCHROOT}${PYTHON3_BIN}" && ! -s "${AMIGENCHROOT}${PYTHON3_LINK}" ]]
then
    echo "Ensuring python3 symlink exists"
    chroot "$AMIGENCHROOT" ln -sf "$PYTHON3_BIN" "$PYTHON3_LINK"
fi

if [[ "${CLOUDPROVIDER}" == "azure" ]]
then
    echo "Configuring waagent"
    #per https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
    chroot "${AMIGENCHROOT}" /usr/sbin/chkconfig waagent on
    chroot "${AMIGENCHROOT}" /usr/bin/sed -i 's|USERCTL="yes"|USERCTL="no"|' /etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'NM_CONTROLLED="no"' >> "${AMIGENCHROOT}"/etc/sysconfig/network-scripts/ifcfg-eth0
    chroot "${AMIGENCHROOT}" /usr/bin/sed -i 's|DHCP_HOSTNAME=localhost.localdomain||' /etc/sysconfig/network-scripts/ifcfg-eth0
    ### Allow cloud-init or user to manage resource disk, matches Azure Marketplace Ubuntu image settings
    chroot "${AMIGENCHROOT}" /usr/bin/sed -i 's|ResourceDisk.Format=y|ResourceDisk.Format=n|' /etc/waagent.conf
    ###
    chroot "${AMIGENCHROOT}" /usr/bin/sed -i 's|Provisioning.Enabled=y|Provisioning.Enabled=n|' /etc/waagent.conf
    chroot "${AMIGENCHROOT}" /usr/bin/sed -i 's|Provisioning.UseCloudInit=n|Provisioning.UseCloudInit=y|' /etc/waagent.conf
    chroot "${AMIGENCHROOT}" /usr/sbin/waagent -force -deprovision
fi

# Calling new CollectManifest function
CollectManifest

echo "Executing Umount.sh"
bash -eux -o pipefail "${ELBUILD}"/Umount.sh || \
    err_exit "Failure encountered with Umount.sh"

echo "amigen7-build.sh complete"'!'
