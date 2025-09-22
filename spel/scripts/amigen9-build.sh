#!/bin/bash
# shellcheck disable=SC2034,SC2046
#
# Execute AMIGen9 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENBOOTSIZE="${SPEL_AMIGENBOOTDEVSZ:-768}"
AMIGENBOOTLABL="${SPEL_AMIGENBOOTDEVLBL:-boot_disk}"
AMIGENBRANCH="${SPEL_AMIGENBRANCH:-main}"
AMIGENCHROOT="${SPEL_AMIGENCHROOT:-/mnt/ec2-root}"
AMIGENFSTYPE="${SPEL_AMIGENFSTYPE:-xfs}"
AMIGENICNCTURL="${SPEL_AMIGENICNCTURL}"
AMIGENMANFST="${SPEL_AMIGENMANFST}"
AMIGENMANFSTAL2023="${SPEL_AMIGENMANFSTAL2023}"
AMIGENPKGGRP="${SPEL_AMIGENPKGGRP:-core}"
AMIGENREPOS="${SPEL_AMIGENREPOS}"
AMIGENREPOSRC="${SPEL_AMIGENREPOSRC}"
AMIGENROOTNM="${SPEL_AMIGENROOTNM}"
AMIGENSOURCE="${SPEL_AMIGEN9SOURCE:-https://github.com/plus3it/AMIgen9.git}"
AMIGENSSMAGENT="${SPEL_AMIGENSSMAGENT}"
AMIGENSTORLAY="${SPEL_AMIGENSTORLAY}"
AMIGENTIMEZONE="${SPEL_TIMEZONE:-UTC}"
AMIGENUEFISIZE="${SPEL_AMIGENUEFIDEVSZ:-128}"
AMIGENUEFILABL="${SPEL_AMIGENUEFIDEVLBL:-UEFI_DISK}"
AMIGENVGNAME="${SPEL_AMIGENVGNAME}"
AWSCFNBOOTSTRAP="${SPEL_AWSCFNBOOTSTRAP}"
AWSCLIV1SOURCE="${SPEL_AWSCLIV1SOURCE}"
AWSCLIV2SOURCE="${SPEL_AWSCLIV2SOURCE:-https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip}"
CLOUDPROVIDER="${SPEL_CLOUDPROVIDER:-aws}"
EXTRARPMS="${SPEL_EXTRARPMS}"
FIPSDISABLE="${SPEL_FIPSDISABLE}"
GRUBTMOUT="${SPEL_GRUBTMOUT:-5}"
HTTP_PROXY="${SPEL_HTTP_PROXY}"
USEDEFAULTREPOS="${SPEL_USEDEFAULTREPOS:-true}"
USEROOTDEVICE="${SPEL_USEROOTDEVICE:-true}"


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
    almalinux-release)
        BUILDER=alma-9
        DEFAULTREPOS=(
            baseos
            appstream
            extras
        )
        ;;
    centos-linux-release | centos-stream-release )
        BUILDER=centos-9stream

        DEFAULTREPOS=(
            baseos
            appstream
            extras-common
        )
        ;;
    oraclelinux-release)
        BUILDER=ol-9

        DEFAULTREPOS=(
            ol9_UEKR7
            ol9_appstream
            ol9_baseos_latest
        )
        ;;
    redhat-release-server|redhat-release)
        BUILDER=rhel-9

        DEFAULTREPOS=(
            rhel-9-appstream-rhui-rpms
            rhel-9-baseos-rhui-rpms
            rhui-client-config-server-9
        )
        ;;
    rocky-release)
        BUILDER=rl-9

        DEFAULTREPOS=(
            baseos
            appstream
            extras
        )
        ;;

    system-release) # Amazon should be shot for this
        BUILDER=amzn-2023

        DEFAULTREPOS=(
            amazonlinux
            kernel-livepatch
        )
        ;;
    *)
        echo "Unknown OS. Aborting" >&2
        exit 1
        ;;
esac
DEFAULTREPOS+=()

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

    # Prepare the build device
    PrepBuildDevice

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

    # Set the size for the /boot partition
    if [[ -z ${AMIGENBOOTSIZE:-} ]]
    then
        err_exit "Setting /boot size to 512MiB" NONE
        DISKSETUPCMD+="-B 512 "
    else
        DISKSETUPCMD+="-B ${AMIGENBOOTSIZE} "
    fi

    # Set the value of the fs-label for the /boot partition
    if [[ -z ${AMIGENBOOTLABL:-} ]]
    then
        err_exit "Setting /boot fs-label to 'boot_disk'." NONE
        DISKSETUPCMD+="-l boot_disk "
    else
        DISKSETUPCMD+="-l ${AMIGENBOOTLABL} "
    fi

    # Set the size for the /boot/efi partition
    if [[ -z ${AMIGENUEFISIZE:-} ]]
    then
        err_exit "Setting /boot/efi size to 256MiB" NONE
        DISKSETUPCMD+="-U 256 "
    else
        DISKSETUPCMD+="-U ${AMIGENUEFISIZE} "
    fi

    # Set the value of the fs-label for the /boot partition
    if [[ -z ${AMIGENUEFILABL:-} ]]
    then
        err_exit "Setting /boot/efi fs-label to 'UEFI_DISK'." NONE
        DISKSETUPCMD+="-L UEFI_DISK "
    else
        DISKSETUPCMD+="-L ${AMIGENUEFILABL} "
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
    if [[ "$BUILDER" == "amzn-2023" ]] && [[ -n ${AMIGENMANFSTAL2023:-} ]]
    then
        # Use custom manifest env for Amazon Linux 2023
        OSPACKAGESTRING+="-M ${AMIGENMANFSTAL2023} "
    elif [[ -n ${AMIGENMANFST:-} ]]
    then
        OSPACKAGESTRING+="-M ${AMIGENMANFST} "
    else
        err_exit "Installing no custom manifest" NONE
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
    if [[ $BUILDER == "ol-9" ]]
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

function PrepBuildDevice {
    local -a DISKS
    local    ROOT_DEV
    local    ROOT_DISK

    # Select the disk to use for the build
    err_exit "Detecting the root device..." NONE
    ROOT_DEV="$( grep ' / ' /proc/mounts | cut -d " " -f 1 )"

    # Use alternate method to find ROOT_DEV (mostly for Azure)
    if [[ ${ROOT_DEV} == "none" ]]
    then
      ROOT_DEV="$(
        blkid | grep "$(
          awk '/\s\s*\/\s\s*/{ print $1 }' /etc/fstab | cut -d '=' -f 2
        )" | sed -e 's/:.*$//'
      )"
    fi

    # Check if root-dev type is supported
    if [[ ${ROOT_DEV} == /dev/nvme* ]]
    then
      ROOT_DISK="${ROOT_DEV//p*/}"
      mapfile -t DISKS < <( echo /dev/nvme*n1 )
    elif [[ ${ROOT_DEV} == /dev/sd* ]]
    then
      ROOT_DISK="${ROOT_DEV%?}"
      mapfile -t DISKS < <( echo /dev/sd[a-z] )
    else
      err_exit "ERROR: This script supports sd or nvme device naming, only. Could not determine root disk from device name: ${ROOT_DEV}"
    fi

    if [[ "$USEROOTDEVICE" = "true" ]]
    then
      AMIGENBUILDDEV="${ROOT_DISK}"
    elif [[ ${#DISKS[@]} -gt 2 ]]
    then
      err_exit "ERROR: This script supports at most 2 attached disks. Detected ${#DISKS[*]} disks"
    else
      AMIGENBUILDDEV="$(echo "${DISKS[@]/$ROOT_DISK}" | tr -d '[:space:]')"
    fi
    err_exit "Using ${AMIGENBUILDDEV} as the build device." NONE

    # Make sure the disk has a GPT label
    err_exit "Checking ${AMIGENBUILDDEV} for a GPT label..." NONE
    if ! blkid "$AMIGENBUILDDEV"
    then
        err_exit "No label detected. Creating GPT label on ${AMIGENBUILDDEV}..." NONE
        parted -s "$AMIGENBUILDDEV" -- mklabel gpt
        blkid "$AMIGENBUILDDEV"
        err_exit "Created empty GPT configuration on ${AMIGENBUILDDEV}" NONE
    else
        err_exit "GPT label detected on ${AMIGENBUILDDEV}" NONE
    fi
}

##########################
## Main program section ##
##########################

set -x
set -e
set -o pipefail

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
