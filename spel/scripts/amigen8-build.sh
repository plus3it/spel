#!/bin/bash
# shellcheck disable=SC2034,SC2046
#
# Execute AMIGen8 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENBOOTSIZE="${SPEL_AMIGENBOOTSIZE}"
AMIGENBRANCH="${SPEL_AMIGENBRANCH:-master}"
AMIGENBUILDDEV="${SPEL_AMIGENBUILDDEV:-/dev/xvda}"
AMIGENCHROOT="${SPEL_AMIGENCHROOT:-/mnt/ec2-root}"
AMIGENFSTYPE="${SPEL_AMIGENFSTYPE:-xfs}"
AMIGENICNCTURL="${SPEL_AMIGENICNCTURL}"
AMIGENMANFST="${SPEL_AMIGENMANFST}"
AMIGENPKGGRP="${SPEL_AMIGENPKGGRP}"
AMIGENREPOS="${SPEL_AMIGENREPOS}"
AMIGENREPOSRC="${SPEL_AMIGENREPOSRC}"
AMIGENROOTNM="${SPEL_AMIGENROOTNM}"
AMIGENSOURCE="${SPEL_AMIGEN8SOURCE:-https://github.com/plus3it/AMIgen8.git}"
AMIGENSSMAGENT="${SPEL_AMIGENSSMAGENT}"
AMIGENSTORLAY="${SPEL_AMIGENSTORLAY}"
AMIGENTIMEZONE="${SPEL_TIMEZONE:-UTC}"
AMIGENVGNAME="${SPEL_AMIGENVGNAME}"
AWSCFNBOOTSTRAP="${SPEL_AWSCFNBOOTSTRAP}"
AWSCLIV1SOURCE="${SPEL_AWSCLIV1SOURCE}"
AWSCLIV2SOURCE="${SPEL_AWSCLIV2SOURCE:-https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip}"
CLOUDPROVIDER="${SPEL_CLOUDPROVIDER:-aws}"
EPELRELEASE="${SPEL_EPELRELEASE}"
EPELREPO="${SPEL_EPELREPO}"
EXTRARPMS="${SPEL_EXTRARPMS}"
FIPSDISABLE="${SPEL_FIPSDISABLE}"
GRUBTMOUT="${SPEL_GRUBTMOUT:-5}"
HTTP_PROXY="${SPEL_HTTP_PROXY}"
USEDEFAULTREPOS="${SPEL_USEDEFAULTREPOS:-true}"


read -r -a BUILDDEPS <<< "${SPEL_BUILDDEPS:-lvm2 yum-utils unzip git}"

ELBUILD="/tmp/el-build"

# Make interactive-execution more-verbose unless explicitly told not to
if [[ $( tty -s ) -eq 0 ]] && [[ -z ${DEBUG:-} ]]
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

# Setup per-builder values
case $( rpm -qf /etc/os-release --qf '%{name}' ) in
    centos-linux-release | centos-stream-release )
        BUILDER=centos-8stream

        DEFAULTREPOS=(
            baseos
            appstream
            extras
        )
        ;;
    centos-release )
        BUILDER=centos-8

        DEFAULTREPOS=(
            BaseOS
            AppStream
            extras
        )
        ;;
    redhat-release-server|redhat-release)
        BUILDER=rhel-8

        DEFAULTREPOS=(
            rhel-8-appstream-rhui-rpms
            rhel-8-baseos-rhui-rpms
            rhui-client-config-server-8
        )
        ;;
    oraclelinux-release)
        BUILDER=ol-8

        DEFAULTREPOS=(
            ol8_UEKR6
            ol8_appstream
            ol8_baseos_latest
        )
        ;;
    *)
        echo "Unknown OS. Aborting" >&2
        exit 1
        ;;
esac
DEFAULTREPOS+=(epel epel-modular)

# Default to enabling default repos
ENABLEDREPOS=$(IFS=,; echo "${DEFAULTREPOS[*]}")

if [[ "$USEDEFAULTREPOS" != "true" ]]
then
    # Enable AMIGENREPOS exclusively when instructed not to use default repos
    ENABLEDREPOS="${AMIGENREPOS}"
elif [[ -n "${AMIGENREPOS:-}" ]]
then
    # When using default repos, also enable AMIGENREPOS if present
    ENABLEDREPOS+=,"${AMIGENREPOS}"
fi

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

# Run the builder-scripts
function BuildChroot {
    local STATUS_MSG

    # Invoke disk-partitioner
    bash -euxo pipefail "${ELBUILD}"/$( ComposeDiskSetupString ) || \
        err_exit "Failure encountered with DiskSetup.sh"

    # Invoke chroot-env disk-mounter
    bash -euxo pipefail "${ELBUILD}"/$( ComposeChrootMountString ) || \
        err_exit "Failure encountered with MkChrootTree.sh"

    # Invoke OS software installer
    bash -euxo pipefail "${ELBUILD}"/$( ComposeOSpkgString ) || \
        err_exit "Failure encountered with OSpackages.sh"

    # Invoke CSP-specific utilities scripts
    case "${CLOUDPROVIDER}" in
        # Invoke AWSutils installer
        aws)
            bash -euxo pipefail "${ELBUILD}"/$( ComposeAWSutilsString ) || \
                err_exit "Failure encountered with AWSutils.sh"
            ;;
        azure)
            (
              export HTTP_PROXY
              bash -euxo pipefail "${ELBUILD}/AzureUtils.sh" || \
                  err_exit "Failure encountered with AzureUtils.sh"
            )
            ;;
        *)
            # Concat exit-message string
            STATUS_MSG="Unsupported value [${CLOUDPROVIDER}] for CLOUDPROVIDER."
            STATUS_MSG="${STATUS_MSG} No provider-specific utilities"
            STATUS_MSG="${STATUS_MSG} will be installed"

            # Log but do not fail-out
            err_exit "${STATUS_MSG}" NONE
            ;;
    esac

    # Post-installation configurator
    bash -euxo pipefail "${ELBUILD}"/$( PostBuildString ) || \
        err_exit "Failure encountered with PostBuild.sh"

    # Collect insallation-manifest
    CollectManifest

    # Invoke unmounter
    bash -euxo pipefail "${ELBUILD}"/Umount.sh -c "${AMIGENCHROOT}" || \
        err_exit "Failure encountered with Umount.sh"
}

# Create a record of the build
function CollectManifest {
    echo "Saving the release info to the manifest"
    grep "PRETTY_NAME=" "${AMIGENCHROOT}/etc/os-release" | \
        cut --delimiter '"' -f2 > /tmp/manifest.txt

    if [[ "${CLOUDPROVIDER}" == "aws" ]]
    then
        if [[ -n "$AWSCLIV1SOURCE" ]]
        then
            echo "Saving the aws-cli-v1 version to the manifest"
            [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
            set +x
            (chroot "${AMIGENCHROOT}" /usr/local/bin/aws1 --version) 2>&1 | \
                tee -a /tmp/manifest.txt
            eval "$XTRACE"
        fi
        if [[ -n "$AWSCLIV2SOURCE" ]]
        then
            echo "Saving the aws-cli-v2 version to the manifest"
            [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
            set +x
            (chroot "${AMIGENCHROOT}" /usr/local/bin/aws2 --version) 2>&1 | \
                tee -a /tmp/manifest.txt
            eval "$XTRACE"
        fi
        if [[ -n "$AWSCFNBOOTSTRAP" ]]
        then
            echo "Saving the cfn bootstrap version to the manifest"
            [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
            set +x
            (chroot "${AMIGENCHROOT}" python3 -m pip list) | \
                grep aws-cfn-bootstrap | tee -a /tmp/manifest.txt
            eval "$XTRACE"
        fi
    elif [[ "${CLOUDPROVIDER}" == "azure" ]]
    then
        echo "Saving the waagent version to the manifest"
        [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
        set +x
        (chroot "${AMIGENCHROOT}" /usr/sbin/waagent --version) 2>&1 | \
            tee -a /tmp/manifest.txt
        eval "$XTRACE"
    fi

    echo "Saving the RPM manifest"
    rpm --root "${AMIGENCHROOT}" -qa | sort -u >> /tmp/manifest.txt
}

# Pick options for the AWSutils install command
function ComposeAWSutilsString {
    local AWSUTILSSTRING

    AWSUTILSSTRING="AWSutils.sh "

    # Set services to enable
    AWSUTILSSTRING+="-t amazon-ssm-agent "

    # Set location for chroot-env
    if [[ ${AMIGENCHROOT} == "/mnt/ec2-root" ]]
    then
        err_exit "Using default chroot-env location [${AMIGENCHROOT}]" NONE
    else
        AWSUTILSSTRING+="-m ${AMIGENCHROOT} "
    fi

    # Whether to install AWS CLIv1
    if [[ -n "${AWSCLIV1SOURCE}" ]]
    then
        AWSUTILSSTRING+="-C ${AWSCLIV1SOURCE} "
    fi

    # Whether to install AWS CLIv2
    if [[ -n "${AWSCLIV2SOURCE}" ]]
    then
        AWSUTILSSTRING+="-c ${AWSCLIV2SOURCE} "
    fi

    # Whether to install AWS SSM-agent
    if [[ -z ${AMIGENSSMAGENT:-} ]]
    then
        err_exit "Skipping install of AWS SSM-agent" NONE
    else
        AWSUTILSSTRING+="-s ${AMIGENSSMAGENT} "
    fi

    # Whether to install AWS InstanceConnect
    if [[ -z ${AMIGENICNCTURL:-} ]]
    then
        err_exit "Skipping install of AWS SSM-agent" NONE
    else
        AWSUTILSSTRING+="-i ${AMIGENICNCTURL} "
    fi

    # Whether to install cfnbootstrap
    if [[ -z "${AWSCFNBOOTSTRAP:-}" ]]
    then
        err_exit "Skipping install of AWS CFN Bootstrap" NONE
    else
        AWSUTILSSTRING+="-n ${AWSCFNBOOTSTRAP} "
    fi

    # Return command-string for AWSutils-script
    echo "${AWSUTILSSTRING}"
}

# Pick options for chroot-mount command
function ComposeChrootMountString {
    local MOUNTCHROOTCMD

    MOUNTCHROOTCMD="MkChrootTree.sh "

    # Set location for chroot-env
    if [[ ${AMIGENCHROOT} == "/mnt/ec2-root" ]]
    then
        err_exit "Using default chroot-env location [${AMIGENCHROOT}]" NONE
    else
        MOUNTCHROOTCMD+="-m ${AMIGENCHROOT} "
    fi

    # Set the filesystem-type to use for OS filesystems
    if [[ ${AMIGENFSTYPE} == "xfs" ]]
    then
        err_exit "Using default fstype [xfs] for boot filesysems" NONE
    else
        MOUNTCHROOTCMD+="-f ${AMIGENFSTYPE} "
    fi

    # Set requested custom storage layout as necessary
    if [[ -z ${AMIGENSTORLAY:-} ]]
    then
        err_exit "Using script-default for boot-volume layout" NONE
    else
        MOUNTCHROOTCMD+="-p ${AMIGENSTORLAY} "
    fi

    # Set device to mount
    if [[ -z ${AMIGENBUILDDEV:-} ]]
    then
        err_exit "Failed to define device to partition"
    else
        MOUNTCHROOTCMD+="-d ${AMIGENBUILDDEV}"
    fi

    # Return command-string for mount-script
    echo "${MOUNTCHROOTCMD}"
}

## # Pick options for disk-setup command
function ComposeDiskSetupString {
    local DISKSETUPCMD

    DISKSETUPCMD="DiskSetup.sh "

    # Set the offset for the OS partition
    if [[ -z ${AMIGENBOOTSIZE:-} ]]
    then
        err_exit "Using minimal offset [17m] for root volumes" NONE
        DISKSETUPCMD+="-B 17m "
    else
        DISKSETUPCMD+="-B ${AMIGENBOOTSIZE} "
    fi

    # Set the filesystem-type to use for OS filesystems
    if [[ ${AMIGENFSTYPE} == "xfs" ]]
    then
        err_exit "Using default fstype [xfs] for boot filesysems" NONE
    fi
    DISKSETUPCMD+="-f ${AMIGENFSTYPE} "

    # Set requested custom storage layout as necessary
    if [[ -z ${AMIGENSTORLAY:-} ]]
    then
        err_exit "Using script-default for boot-volume layout" NONE
    else
        DISKSETUPCMD+="-p ${AMIGENSTORLAY} "
    fi

    # Set LVM2 or bare disk-formatting
    if [[ -n ${AMIGENVGNAME:-} ]]
    then
        DISKSETUPCMD+="-v ${AMIGENVGNAME} "
    elif [[ -n ${AMIGENROOTNM:-} ]]
    then
        DISKSETUPCMD+="-r ${AMIGENROOTNM} "
    fi

    # Set device to carve
    if [[ -z ${AMIGENBUILDDEV:-} ]]
    then
        err_exit "Failed to define device to partition"
    else
        DISKSETUPCMD+="-d ${AMIGENBUILDDEV}"
    fi

    # Return command-string for disk-setup script
    echo "${DISKSETUPCMD}"
}

# Pick options for the OS-install command
function ComposeOSpkgString {
    local OSPACKAGESTRING

    OSPACKAGESTRING="OSpackages.sh "

    # Set location for chroot-env
    if [[ ${AMIGENCHROOT} == "/mnt/ec2-root" ]]
    then
        err_exit "Using default chroot-env location [${AMIGENCHROOT}]" NONE
    else
        OSPACKAGESTRING+="-m ${AMIGENCHROOT} "
    fi

    # Pick custom yum repos
    if [[ -z ${ENABLEDREPOS:-} ]]
    then
        err_exit "Using script-default yum repos" NONE
    else
        OSPACKAGESTRING+="-a ${ENABLEDREPOS} "
    fi

    # Custom repo-def RPMs to install
    if [[ -z ${AMIGENREPOSRC:-} ]]
    then
        err_exit "Installing no custom repo-config RPMs" NONE
    else
        OSPACKAGESTRING+="-r ${AMIGENREPOSRC} "
    fi

    # Add custom manifest file
    if [[ -z ${AMIGENMANFST:-} ]]
    then
        err_exit "Installing no custom manifest" NONE
    else
        OSPACKAGESTRING+="-M ${AMIGENREPOSRC} "
    fi

    # Add custom pkg group
    if [[ -z ${AMIGENPKGGRP:-} ]]
    then
        err_exit "Installing no custom package group" NONE
    else
        OSPACKAGESTRING+="-g ${AMIGENPKGGRP} "
    fi

    # Add extra rpms
    if [[ -z ${EXTRARPMS:-} ]]
    then
        err_exit "Installing no extra rpms" NONE
    else
        OSPACKAGESTRING+="-e ${EXTRARPMS} "
    fi

    # Customization for Oracle Linux
    if [[ $BUILDER == "ol-8" ]]
    then
        # Exclude Unbreakable Enterprise Kernel
        OSPACKAGESTRING+="-x kernel-uek,redhat*,*rhn*,*spacewalk*,*ulninfo* "

        # DNF hack
        OSPACKAGESTRING+="--setup-dnf ociregion=,ocidomain=oracle.com "
    fi

    # Return command-string for OS-script
    echo "${OSPACKAGESTRING}"
}

function PostBuildString {
    local POSTBUILDCMD

    POSTBUILDCMD="PostBuild.sh "

    # Set the filesystem-type to use for OS filesystems
    if [[ ${AMIGENFSTYPE} == "xfs" ]]
    then
        err_exit "Using default fstype [xfs] for boot filesysems" NONE
    fi
    POSTBUILDCMD+="-f ${AMIGENFSTYPE} "

    # Set location for chroot-env
    if [[ ${AMIGENCHROOT} == "/mnt/ec2-root" ]]
    then
        err_exit "Using default chroot-env location [${AMIGENCHROOT}]" NONE
    else
        POSTBUILDCMD+="-m ${AMIGENCHROOT} "
    fi

    # Set AMI starting time-zone
    if [[ ${AMIGENTIMEZONE} == "UTC" ]]
    then
        err_exit "Using default AMI timezone [${AMIGENCHROOT}]" NONE
    else
        POSTBUILDCMD+="-z ${AMIGENTIMEZONE} "
    fi

    # Set image GRUB_TIMEOUT value
    POSTBUILDCMD+="--grub-timeout ${GRUBTMOUT}"

    # Return command-string for OS-script
    echo "${POSTBUILDCMD}"
}

# Disable strict hostkey checking
function DisableStrictHostCheck {
    local HOSTVAL

    if [[ ${1:-} == '' ]]
    then
        err_exit "No connect-string passed to function [${0}]"
    else
        HOSTVAL="$( sed -e 's/^.*@//' -e 's/:.*$//' <<< "${1}" )"
    fi

    # Git host-target parameters
    err_exit "Disabling SSH's strict hostkey checking for ${HOSTVAL}" NONE
    (
        printf "Host %s\n" "${HOSTVAL}"
        printf "  Hostname %s\n" "${HOSTVAL}"
        printf "  StrictHostKeyChecking off\n"
    ) >> "${HOME}/.ssh/config" || \
    err_exit "Failed disabling SSH's strict hostkey checking"
}



##########################
## Main program section ##
##########################

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

if [[ -n "${HTTP_PROXY:-}" ]]
then
    echo "Setting Git Config Proxy"
    git config --global http.proxy "${HTTP_PROXY}"
    echo "Set git config to use proxy"
fi

if [[ -n "${EPELRELEASE:-}" ]]
then
    {
        STDERR=$( yum -y install "$EPELRELEASE" 2>&1 1>&$out );
    } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
fi

if [[ -n "${EPELREPO:-}" ]]
then
    yum-config-manager --enable "$EPELREPO" > /dev/null
fi

echo "Installing custom repo packages in the builder box"
IFS="," read -r -a BUILDER_AMIGENREPOSRC <<< "$AMIGENREPOSRC"
for RPM in "${BUILDER_AMIGENREPOSRC[@]}"
do
    {
        STDERR=$( yum -y install "$RPM" 2>&1 1>&$out );
    } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
done

echo "Enabling repos in the builder box"
yum-config-manager --disable "*" > /dev/null
yum-config-manager --enable "$ENABLEDREPOS" > /dev/null

echo "Installing specified extra packages in the builder box"
IFS="," read -r -a BUILDER_EXTRARPMS <<< "$EXTRARPMS"
for RPM in "${BUILDER_EXTRARPMS[@]}"
do
    {
        STDERR=$( yum -y install "$RPM" 2>&1 1>&$out );
    } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
done

# Disable strict host-key checking when doing git-over-ssh
if [[ ${AMIGENSOURCE} =~ "@" ]]
then
    DisableStrictHostCheck "${AMIGENSOURCE}"
fi

# Dismount /oldroot as needed
if [[ $( mountpoint /oldroot ) =~ "is a mountpoint" ]]
then
    err_exit "Dismounting /oldroot..." NONE
    umount /oldroot || \
        err_exit "Failed dismounting /oldroot"
fi

# Null out the build-dev's VTOC
echo "Checking ${SPEL_AMIGENBUILDDEV} for VTOC to nuke..."
if [[ -b "${SPEL_AMIGENBUILDDEV}" ]]
then
    echo "${SPEL_AMIGENBUILDDEV} is a valid block device. Nuking VTOC... "

    retry 5 dd if=/dev/urandom of="${SPEL_AMIGENBUILDDEV}" bs=1024 count=10240
    echo "Cleared."
fi

# Ensure build-tools directory exists
if [[ ! -d ${ELBUILD} ]]
then
    err_exit "Creating build-tools directory [${ELBUILD}]..." NONE
    install -dDm 000755 "${ELBUILD}" || \
        err_exit "Failed creating build-tools directory"
fi

# Pull build-tools from git clone-source
git clone --branch "${AMIGENBRANCH}" "${AMIGENSOURCE}" "${ELBUILD}"

# Execute build-tools
BuildChroot
