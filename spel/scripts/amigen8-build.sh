#!/bin/bash
# shellcheck disable=SC2034,SC2046
#
# Execute AMIGen8 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENBOOTSIZE="${SPEL_AMIGEN8_BOOTSIZE:-UNDEF}"
AMIGENBRANCH="${SPEL_AMIGEN8BRANCH:-master}"
AMIGENBUILDDEV="${SPEL_AMIGEN8_BUILDDEV:-/dev/xvda}"
AMIGENCHROOT="${SPEL_AMIGEN8_CHROOT:-/mnt/ec2-root}"
AMIGENCLIV1SRC="${SPEL_AMIGEN8_CLIV1SRC:-UNDEF}"
AMIGENCLIV2SRC="${SPEL_AMIGEN8_CLIV2SRC:-UNDEF}"
AMIGENFSTYPE="${SPEL_AMIGEN8_FSTYPE:-xfs}"
AMIGENREPOS="${SPEL_AMIGEN8_REPOS:-UNDEF}"
AMIGENREPOSRC="${SPEL_AMIGEN8_REPOSRC:-UNDEF}"
AMIGENROOTNM="${SPEL_AMIGEN8_ROOTNM:-UNDEF}"
AMIGENSOURCE="${SPEL_AMIGEN8SOURCE:-https://github.com/plus3it/AMIgen8.git}"
AMIGENSSMAGENT="${SPEL_AMIGEN8_SSMAGENT:-UNDEF}"
AMIGENSTORLAY="${SPEL_AMIGEN8_STORLAY:-UNDEF}"
AMIGENVGNAME="${SPEL_AMIGEN8_VGNAME:-UNDEF}"
DEBUG="${DEBUG:-UNDEF}"
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

   # Return command-string for OS-script
   echo "${OSPACKAGESTRING}"
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
   if [[ ${AMIGENCLIV1SRC} == "UNDEF" ]]
   then
      err_exit "Skipping install of AWS CLIv1" NONE
   else
      AWSUTILSSTRING+="-C ${AMIGENCLIV1SRC} "
   fi

   # Whether to install AWS CLIv2
   if [[ ${AMIGENCLIV2SRC} == "UNDEF" ]]
   then
      err_exit "Skipping install of AWS CLIv2" NONE
   else
      AWSUTILSSTRING+="-c ${AMIGENCLIV2SRC} "
   fi

   # Whether to install AWS SSM-agent
   if [[ ${AMIGENSSMAGENT} == "UNDEF" ]]
   then
      err_exit "Skipping install of AWS SSM-agent" NONE
   else
      AWSUTILSSTRING+="-s ${AMIGENSSMAGENT}"
   fi

   # Return command-string for AWSutils-script
   echo "${AWSUTILSSTRING}"

}

# Run the builder-scripts
function BuildChroot {
   local PATHY

   PATHY="${ELBUILD}/$( sed -e 's#^.*/##' -e 's/\.git.*$//' <<< "${AMIGENSOURCE}" )"

   # Invoke disk-partitioner
   bash -x "${PATHY}"/$( ComposeDiskSetupString ) || \
     err_exit "Failure encountered with DiskSetup.sh"

   # Invoke chroot-env disk-mounter
   bash -x "${PATHY}"/$( ComposeChrootMountString )
     err_exit "Failure encountered with MkChrootTree.sh"

   # Invoke OS software installer
   bash -x "${PATHY}"/$( ComposeOSpkgString ) 
     err_exit "Failure encountered with OSpackages.sh"

   # Invoke AWSutils installer
   bash -x "${PATHY}"/$( ComposeAWSutilsString )
     err_exit "Failure encountered with AWSutils.sh"

   # Invoke unmounter
   bash -x "${PATHY}"/Umount.sh -c "${AMIGENCHROOT}"
     err_exit "Failure encountered with Umount.sh"
}



##########################
## Main program section ##
##########################

# Disable strict host-key checking when doing git-over-ssh
if [[ ${AMIGENSOURCE} =~ "@" ]]
then
   DisableStrictHostCheck "${AMIGENSOURCE}"
fi

# Ensure build-tools directory exists
if [[ ! -d ${ELBUILD} ]]
then
   err_exit "Creating build-tools directory [${ELBUILD}]..." NONE
   install -dDm 000755 "${ELBUILD}" || \
     err_exit "Failed creating build-tools directory"
fi

# Pull build-tools from git clone-source
( cd "${ELBUILD}" && git clone --branch "${AMIGENBRANCH}" "${AMIGENSOURCE}" )

# Execute build-tools
BuildChroot

