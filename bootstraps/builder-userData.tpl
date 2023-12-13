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
export AMIGEN_SOURCE="SOURCE_SUBST"
export AMIGEN_BRANCH="BRANCH_SUBST"
export BOOTDEVSZ="BOOTDEVSZ_SUBST"
export CFNBOOTSTRAP="CFNBOOTSTRAP_SUBST"
export CHROOTDEV="$(
  parted -l 2>&1 | \
  awk -F: '/unrecognised disk label/{ print $2 }' | \
  sed 's/\s\s*//g'
)"
export CLIV2SOURCE="CLIV2SOURCE_SUBST"
export FSTYPE="FSTYP_SUBST"
export LABEL_BOOT="BOOTLBL_SUBST"
export LABEL_UEFI="UEFILBL_SUBST"
export MKFSFORCEOPT="-f"
export SSMAGENT="SSMAGENT_SUBST"
export UEFIDEVSZ="96"
export VGNAME="RootVG"


# Install needed RPMs
if [[ $( rpm --quiet -q git )$? -ne 0 ]]
then
  dnf install -y \
    dosfstools \
    git \
    lvm2 \
    unzip \
    yum-utils
fi

# Clone AMIgen9 into sensible location
git clone "${AMIGEN_SOURCE}" -b "${AMIGEN_BRANCH}" /root/AMIgen

# Enter project-directory
cd /root/AMIgen

bash -x DiskSetup.sh -v "${VGNAME}"
bash -x MkChrootTree.sh -d "${CHROOTDEV}"
bash -x OSpackages.sh
bash -x AWSutils.sh \
  -c "${CLIV2SOURCE}" \
  -n "${CFNBOOTSTRAP}" \
  -s "${SSMAGENT}" \
  -t amazon-ssm-agent
bash -x PostBuild.sh -f "${FSTYPE}"

systemctl poweroff
