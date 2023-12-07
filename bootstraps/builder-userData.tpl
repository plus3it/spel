#!/bin/bash
set -euo pipefail
#
# A userData payload-script that
# * Downloads relevant AMIgen content
# * Appropriately Executes said content
# * Powers off the executing-system upon successful completion of the AMIgen
#   content
#
################################################################################
AMIGEN_SOURCE="SOURCE_SUBST"
AMIGEN_BRANCH="BRANCH_SUBST" 
BOOTDEVSZ="BOOTDEVSZ_SUBST"
CHROOTDEV="$(
  parted -l 2>&1 | \
  awk -F: '/unrecognised disk label/{ print $2 }' | \
  sed 's/\s\s*//g'
)"
FSTYPE="FSTYP_SUBST"
LABEL_BOOT="BOOTLBL_SUBST"
LABEL_UEFI="UEFILBL_SUBST"
MKFSFORCEOPT="-f"
UEFIDEVSZ="96"
VGNAME="RootVG"

export BOOTDEVSZ CHROOTDEV FSTYPE LABEL_BOOT LABEL_UEFI MKFSFORCEOPT UEFIDEVSZ VGNAME


# Install git as needed
if [[ $( rpm --quiet -q git )$? -ne 0 ]]
then
  dnf install -y \
    git \
    lvm2
fi

# Clone AMIgen9 into sensible location
git clone "${AMIGEN_SOURCE}" -b "${AMIGEN_BRANCH}" /root/AMIgen

# Enter project-directory
cd /root/AMIgen

bash -x DiskSetup.sh -v "${VGNAME}"
bash -x MkChrootTree.sh -d "${CHROOTDEV}"
bash -x OSpackages.sh
