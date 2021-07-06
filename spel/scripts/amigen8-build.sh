#!/bin/bash
# shellcheck disable=SC2034,SC2046
#
# Execute AMIGen8 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENBOOTSIZE="${SPEL_AMIGENBOOTSIZE:-UNDEF}"
AMIGENBRANCH="${SPEL_AMIGENBRANCH:-master}"
AMIGENBUILDDEV="${SPEL_AMIGENBUILDDEV:-/dev/xvda}"
AMIGENCHROOT="${SPEL_AMIGENCHROOT:-/mnt/ec2-root}"
AMIGENFSTYPE="${SPEL_AMIGENFSTYPE:-xfs}"
AMIGENICNCTURL="${SPEL_AMIGENICNCTURL:-UNDEF}"
AMIGENMANFST="${SPEL_AMIGENMANFST}"
AMIGENPKGGRP="${SPEL_AMIGENPKGGRP:-UNDEF}"
AMIGENREPOS="${SPEL_AMIGENREPOS:-UNDEF}"
AMIGENREPOSRC="${SPEL_AMIGENREPOSRC:-UNDEF}"
AMIGENROOTNM="${SPEL_AMIGENROOTNM:-UNDEF}"
AMIGENSOURCE="${SPEL_AMIGEN8SOURCE:-https://github.com/plus3it/AMIgen8.git}"
AMIGENSSMAGENT="${SPEL_AMIGENSSMAGENT:-UNDEF}"
AMIGENSTORLAY="${SPEL_AMIGENSTORLAY:-UNDEF}"
AMIGENTIMEZONE="${SPEL_TIMEZONE:-UTC}"
AMIGENVGNAME="${SPEL_AMIGENVGNAME:-UNDEF}"
AWSCLIV1SOURCE="${SPEL_AWSCLIV1SOURCE:-https://s3.amazonaws.com/aws-cli/awscli-bundle.zip}"
AWSCLIV2SOURCE="${SPEL_AWSCLIV2SOURCE:-https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip}"
CLOUDPROVIDER="${SPEL_CLOUDPROVIDER:-aws}"
DEBUG="${DEBUG:-UNDEF}"
EPELRELEASE="${SPEL_EPELRELEASE:-https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm}"
EPELREPO="${SPEL_EPELREPO:-epel}"
FIPSDISABLE="${SPEL_FIPSDISABLE}"


read -r -a BUILDDEPS <<< "${SPEL_BUILDDEPS:-lvm2 yum-utils unzip git}"

ELBUILD="/tmp/el-build"

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

export FIPSDISABLE

# Run the builder-scripts
function BuildChroot {

   # Invoke disk-partitioner
   bash -euxo pipefail "${ELBUILD}"/$( ComposeDiskSetupString ) || \
     err_exit "Failure encountered with DiskSetup.sh"

   # Invoke chroot-env disk-mounter
   bash -euxo pipefail "${ELBUILD}"/$( ComposeChrootMountString ) || \
     err_exit "Failure encountered with MkChrootTree.sh"

   # Invoke OS software installer
   bash -euxo pipefail "${ELBUILD}"/$( ComposeOSpkgString ) || \
     err_exit "Failure encountered with OSpackages.sh"

   # Invoke AWSutils installer
   bash -euxo pipefail "${ELBUILD}"/$( ComposeAWSutilsString ) || \
     err_exit "Failure encountered with AWSutils.sh"

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
   cat "${AMIGENCHROOT}/etc/redhat-release" > /tmp/manifest.txt

   if [[ "${CLOUDPROVIDER}" == "aws" ]]
   then
      if [[ -n "$AWSCLIV1SOURCE" ]]
      then
         echo "Saving the aws cli version to the manifest"
         [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
         set +x
      (
         chroot "${AMIGENCHROOT}" bash -c "(
            [[ -x /usr/bin/aws ]] && /usr/bin/aws --version
            [[ -x /usr/local/bin/aws ]] && /usr/local/bin/aws --version
         )" >> /tmp/manifest.txt 2>&1
      )
      eval "$XTRACE"
      fi
      if [[ -n "$AWSCLIV2SOURCE" ]]
      then
         echo "Saving the aws-cli-v2 version to the manifest"
         [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
         set +x
      (
         chroot "${AMIGENCHROOT}" bash -c "(
            [[ -x /usr/local/bin/aws2 ]] && /usr/local/bin/aws2 --version
            )" >> /tmp/manifest.txt 2>&1
      )
      eval "$XTRACE"
      fi

      ###
      # AWS SSM-Agent is insalled via RPM: if the AWS
      # SSM-Agent is installed, it will show # up in the
      # `rpm` output (below)
      ###

   elif [[ "${CLOUDPROVIDER}" == "azure" ]]
   then
      echo "Saving the waagent version to the manifest"
      [[ -o xtrace ]] && XTRACE='set -x' || XTRACE='set +x'
      set +x
      chroot "${AMIGENCHROOT}" /usr/sbin/waagent --version >> /tmp/manifest.txt 2>&1
      eval "$XTRACE"
   fi

   echo "Saving the RPM manifest"
   rpm --root "${AMIGENCHROOT}" -qa | sort -u >> /tmp/manifest.txt

}

# Pick options for the AWSutils install command
function ComposeAWSutilsString {
   local AWSUTILSSTRING

   AWSUTILSSTRING="AWSutils.sh "

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
   if [[ ${AMIGENSSMAGENT} == "UNDEF" ]]
   then
      err_exit "Skipping install of AWS SSM-agent" NONE
   else
      AWSUTILSSTRING+="-s ${AMIGENSSMAGENT} "
   fi

   # Whether to install AWS InstanceConnect
   if [[ ${AMIGENICNCTURL} == "UNDEF" ]]
   then
      err_exit "Skipping install of AWS SSM-agent" NONE
   else
      AWSUTILSSTRING+="-i ${AMIGENICNCTURL} "
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
   if [[ ${AMIGENSTORLAY} == "UNDEF" ]]
   then
      err_exit "Using script-default for boot-volume layout" NONE
   else
      MOUNTCHROOTCMD+="-p ${AMIGENSTORLAY} "
   fi

   # Set device to mount
   if [[ ${AMIGENBUILDDEV} == "UNDEF" ]]
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
   if [[ ${AMIGENBOOTSIZE} == "UNDEF" ]]
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
   if [[ ${AMIGENSTORLAY} == "UNDEF" ]]
   then
      err_exit "Using script-default for boot-volume layout" NONE
   else
      DISKSETUPCMD+="-p ${AMIGENSTORLAY} "
   fi

   # Set LVM2 or bare disk-formatting
   if [[ ${AMIGENVGNAME} != "UNDEF" ]]
   then
      DISKSETUPCMD+="-v ${AMIGENVGNAME} "
   elif [[ ${AMIGENROOTNM} != "UNDEF" ]]
   then
      DISKSETUPCMD+="-r ${AMIGENROOTNM} "
   fi

   # Set device to carve
   if [[ ${AMIGENBUILDDEV} == "UNDEF" ]]
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
   if [[ ${AMIGENREPOS} == "UNDEF" ]]
   then
      err_exit "Using script-default yum repos" NONE
   else
      OSPACKAGESTRING+="-a ${AMIGENREPOS} "
   fi

   # Custom repo-def RPMs to install
   if [[ ${AMIGENREPOSRC} == "UNDEF" ]]
   then
      err_exit "Installing no custom repo-config RPMs" NONE
   else
      OSPACKAGESTRING+="-r ${AMIGENREPOSRC}"
   fi

   # Add custom manifest file
   if [[ ${AMIGENMANFST} == "UNDEF" ]]
   then
      err_exit "Installing no custom mainfest" NONE
   else
      OSPACKAGESTRING+="-M ${AMIGENREPOSRC}"
   fi

   # Add custom pkg group
   if [[ ${AMIGENPKGGRP} == "UNDEF" ]]
   then
      err_exit "Installing no custom package group" NONE
   else
      OSPACKAGESTRING+="-g ${AMIGENPKGGRP}"
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
   echo "%s is a valid block device. Nuking VTOC... " "${SPEL_AMIGENBUILDDEV}"

   ITER=0
   while [[ $( sfdisk -d "${SPEL_AMIGENBUILDDEV}" ) != "" ]]
   do
      dd if=/dev/urandom of="${SPEL_AMIGENBUILDDEV}" bs=1024 \
         count=10240 > /dev/null 2>&1
      sleep 5
      (( ITER++ ))
      if [[ ${ITER} -ge 5 ]]
      then
         err_exit "Failed clearing VTOC"
      fi
   done
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
