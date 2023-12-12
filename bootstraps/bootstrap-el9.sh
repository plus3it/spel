#!/bin/bash
#
# Script to launch a 2-disk, self-provisioning EC2. After provisioning, the
# script then detaches both disks and re-attaches the secondary EBS as the root
# EBS and registers it.
#
# Note: This script is intended as a temporary workaround: it should only be
#       used until such time that Red Hat fixes RHEL-17421 and/or there is an
#       improved chroot-builder for AWS (and Azure) that negates the impacts of
#       RHEL-17421
################################################################################
# shellcheck disable=SC2054,SC2207
AMI_DESCRIPTION_ARR=(
  STIG-partitioned [*NOT HARDENED*],
  LVM-enabled,
  \"minimal\" RHEL 9 AMI
  with updates through $( date '+%Y-%m-%d' )
  Default username 'maintuser'.
  See https://github.com/plus3it/spel
)
AMI_DESCRIPTION_STR="${AMI_DESCRIPTION_ARR[*]}"
AWS_HOSTED="${SPEL_HOSTING_ENVIRONMENT:-aws}"
AMI_IDENTIFIER="${SPEL_IDENTIFIER:-spel-minimal-rhel-9-hvm}"
AMI_PERMISSIONS="${SPEL_AMI_PERMISSIONS:-public}"
AMI_VERSION="${SPEL_VERSION:-0.0.0}"
AWS_REGION="${SPEL_AWS_REGION:-}"
BOOTSTRAP_AMI="${AMIGEN9_BOOTSTRAP_AMI:-}"
BUILD_SUBNET="${SPEL_SUBNET:-}"
BUILD_VPC_ID="${SPEL_VPC_ID:-}"
CURL_CMD=()
INSTANCE_TYPE="${SPEL_INSTANCE_TYPE:-t3.large}"
METADATA_URL="http://169.254.169.254"
PROGNAME="$( basename "${0}" )"
PROGPATH="$( dirname "${0}" )"

export METADATA_URL

function UseCurlCmd {
  local    IMDS_TOKEN

  # Try to snarf an IMDS token
  IMDS_TOKEN="$(
    curl -sk \
      -X PUT "${METADATA_URL}/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
  )"

  # Define curl command-options based availability of IMDSv2
  if [[ ${IMDS_TOKEN:-} == "" ]]
  then
    CURL_CMD=(
      curl
      -sk
    )
  else
    CURL_CMD=(
      curl
      -sk
      -H "'X-aws-ec2-metadata-token: ${IMDS_TOKEN}'"
    )
  fi
  CURL_CMD+=("${METADATA_URL}/latest")

  return 0
}

function CreateBuilderSg {
  local CONTROL_MAC
  local CONTROL_VPC
  local RUN_SEC_GRP

  # Compute build-instanc'e VPC as needed
  if [[ -n ${BUILD_VPC_ID:-} ]]
  then
    CONTROL_VPC="${BUILD_VPC_ID}"
  else
    # shellcheck disable=SC2145
    CONTROL_MAC="$(
      "${CURL_CMD[@]}/meta-data/network/interfaces/macs"
    )"
    # shellcheck disable=SC2145
    CONTROL_VPC="$(
      "${CURL_CMD[@]}/meta-data/network/interfaces/macs/${CONTROL_MAC}/vpc-id"
    )"
  fi

  RUN_SEC_GRP="$(
    aws ec2 create-security-group \
      --region "${AWS_REGION}" \
      --description "Packer Build" \
      --group-name "PackerBuilder_$( date '+%Y%m%d%H%M' )" \
      --vpc-id "${CONTROL_VPC}" \
      --output text
  )"

  if [[ -n ${RUN_SEC_GRP} ]]
  then
    echo "${RUN_SEC_GRP}"
    return 0
  else
    echo "Failed"
    exit 1
  fi
}

# shellcheck disable=SC2016
function GetBootstrapAmi {
  local AMI_OWNER
  local TARGET_AMI

  case "${AWS_REGION}" in
    "us-gov-"*)
      AMI_OWNER="219670896067"
      ;;
    *)
      AMI_OWNER="amazon"
      ;;
  esac

  TARGET_AMI="$(
    aws \
      --region "${AWS_REGION}" ec2 describe-images \
      --owners "${AMI_OWNER}" \
      --query 'sort_by(Images, &CreationDate)[?
        ( BootMode == `uefi-preferred` || BootMode == `uefi`) &&
        Architecture == `x86_64`].[ImageId]' \
      --filters "Name=name,Values=RHEL-9*" \
      --output text | \
   tail -1
  )"

  # Return value if found
  if [[ ${TARGET_AMI} == "ami-"* ]]
  then
    echo "${TARGET_AMI}"
    return 0
  else
    echo "Not able to compute bootstrap-AMI ID"
    return 1
  fi
}

function BuildCleanup {
  # Clean up builder EC2
  printf "Terminating %s... " "${BUILDER_ID}"
  if [[ $(
      aws ec2 terminate-instances \
        --query 'TerminatingInstances[].CurrentState.Name' \
        --output text \
        --instance-ids "${BUILDER_ID}" || ( echo "FAILED!" ; exit 1 )
    ) == "terminated" ]]
  then
    echo "Done"
  else
    echo
  fi

  # Clean up Storage
  for VOL_ID in "${BUILDER_ROOT}" "${BUILDER_CHROOT}"
  do
    printf "Deleting volume %s... " "${VOL_ID}"
    aws ec2 delete-volume --volume-id "${VOL_ID}" || ( echo "FAILED!" ; exit 1 )
    echo "Done"
  done

  # Wait for builder-instance to reach fully-terminated state
  printf 'Waiting for %s to reach fully-terminated state' "${BUILDER_ID}"
  while true
  do
    printf "."
    if [[ $(
      aws ec2 describe-instances \
        --query 'Reservations[].Instances[].State.Name' \
        --output text \
        --instance-ids "${BUILDER_ID}"
    ) ==  "terminated" ]]
    then
      echo " Done"
      break
    fi
    sleep 5
  done

  # Clean up builder security-group
  printf "Deleting security-group %s... " "${RUN_SEC_GRP}"
  aws ec2 delete-security-group --group-id "${RUN_SEC_GRP}" || \
    ( echo "FAILED!" ; exit 1 )
  echo "Done"
}

function DetachVolumes {
  local VOL_ID
  local VOL_STAT

  for VOL_ID in "${BUILDER_ROOT}" "${BUILDER_CHROOT}"
  do
    printf "Detaching %s from %s... " "${VOL_ID}" "${BUILDER_ID}"

    VOL_STAT="$(
      aws ec2 detach-volume \
      --volume-id "${VOL_ID}" \
      --output text \
      --instance-id "${BUILDER_ID}"
    )"

    # In case there's a error during detach-request
    if [[ -z "${VOL_STAT}" ]]
    then
      printf "Error while detaching %s. Aborting" "${VOL_ID}"
      echo
      exit
    else
      echo "Detach in progress"
    fi

    # Wait for the detach to complete
    while true
    do
      if [[ $(
          aws ec2 describe-volumes \
            --query 'Volumes[].State' \
            --output text \
            --volume-ids "${VOL_ID}"
        ) == "available" ]]
      then
        echo "Done"
        break
      fi
    done
  done
}


##################
## Main Program ##
##################
if [[ ${PROGPATH} == "." ]]
then
  PROGPATH=""
else
  PROGPATH="${PROGPATH}/"
fi

# Cobble together the curl command and base options-set
if [[ ${AWS_HOSTED} == "aws" ]]
then
  UseCurlCmd
fi

# Set AWS_REGION as necessary
if [[ -z ${AWS_REGION:-} ]]
then
  # shellcheck disable=SC2145
  AWS_REGION="$( "${CURL_CMD[@]}/meta-data/placement/region" )"
fi

# Search for suitable bootstrap-AMI as necessary
if [[ -z ${BOOTSTRAP_AMI:-} ]]
then
  BOOTSTRAP_AMI="$( GetBootstrapAmi )"
fi

# Create a dummy security-group to attach to the builder-EC2
printf "Creating dummy security-group... "
RUN_SEC_GRP="$( CreateBuilderSg )"
echo "Done: ${RUN_SEC_GRP} created"

# Compute build-subnet as necessary
# shellcheck disable=SC2145
if [[ -z ${BUILD_SUBNET:-} ]]
then
  CONTROLLER_MAC="$( "${CURL_CMD[@]}/meta-data/network/interfaces/macs" )"
  BUILD_SUBNET="$(
    "${CURL_CMD[@]}/meta-data/network/interfaces/macs/${CONTROLLER_MAC}/subnet-id"
  )"
fi

# Create userData payload from template-file
sed -e 's#SOURCE_SUBST#https://github.com/plus3it/AMIgen9.git#' \
    -e 's#BRANCH_SUBST#main#' \
    -e 's#BOOTDEVSZ_SUBST#512#' \
    -e 's#BOOTLBL_SUBST#boot_disk#' \
    -e 's#CFNBOOTSTRAP_SUBST#https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz#' \
    -e 's#CLIV2SOURCE_SUBST#https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip#' \
    -e 's#FSTYP_SUBST#xfs#' \
    -e 's#SSMAGENT_SUBST#https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm#' \
    -e 's#UEFIDEVSZ_SUBST#96#' \
    -e 's#UEFILBL_SUBST#UEFI_DISK#' \
    -e 's#VGNAME_SUBST#RootVG#' \
   "${PROGPATH}builder-userData.tpl" > "${PROGPATH}builder-userData.runtime"

BUILDER_ID="$(
  aws ec2 run-instances \
    --block-device-mappings \
      'DeviceName=/dev/sda1,Ebs={VolumeType=gp3}' \
      'DeviceName=/dev/sdf,Ebs={VolumeType=gp3,VolumeSize=25}' \
    --image-id "${BOOTSTRAP_AMI}" \
    --instance-type "${INSTANCE_TYPE}" \
    --output text \
    --query 'Instances[].InstanceId' \
    --region "${AWS_REGION}" \
    --security-group-ids "${RUN_SEC_GRP}" \
    --subnet-id "${BUILD_SUBNET}" \
    --tag-specifications 'ResourceType=instance,Tags=[
        {Key=Name,Value=Packer Chroot-build}
      ]' \
    --user-data "file://${PROGPATH}builder-userData.runtime"
)"

# shellcheck disable=SC2016
if [[ -n ${BUILDER_ID} ]]
then
  # Announce builder launch-status
  echo "Builder EC2 [${BUILDER_ID}] has launched... "

  # Get volume-mappings
  # shellcheck disable=SC2006
  BUILDER_ROOT="$(
    aws ec2 describe-instances \
      --query 'Reservations[].Instances[].BlockDeviceMappings[?
          DeviceName == `/dev/sda1`
        ].Ebs.VolumeId' \
      --output text \
      --instance-ids "${BUILDER_ID}"
  )"
  # shellcheck disable=SC2006
  BUILDER_CHROOT="$(
    aws ec2 describe-instances \
      --query 'Reservations[].Instances[].BlockDeviceMappings[?
          DeviceName == `/dev/sdf`
        ].Ebs.VolumeId' \
      --output text \
      --instance-ids "${BUILDER_ID}"
  )"
  echo "Checking state in 60 seconds"
  sleep 60
else
  echo "Does not appear builder-instance launched. Aborting..."
  exit 1
fi

# Wait for instance to stop
while true
do
  if [[ $(
    aws ec2 describe-instances \
      --query 'Reservations[].Instances[].State.Name' \
      --output text \
      --instance-ids "${BUILDER_ID}"
  ) == "stopped" ]]
  then
    echo "${BUILDER_ID} has stopped"
    break
  else
    echo "${BUILDER_ID} still has not finished: checking again in 60 seconds"
  fi
  sleep 60
done

# Call funciton to detach volumes
DetachVolumes

# Attach chroot-disk as boot-disk
printf "Attaching %s to %s... " "${BUILDER_CHROOT}" "${BUILDER_ID}"
aws ec2 attach-volume \
  --volume-id "${BUILDER_CHROOT}" \
  --device /dev/sda1 \
  --output text \
  --query 'State' \
  --instance-id "${BUILDER_ID}" || ( echo FAILED! ; exit 1 )

# Create image from EC2
echo "Registering image from ${BUILDER_ID}... "
NEW_IMAGE="$( aws ec2 create-image \
  --name "${AMI_IDENTIFIER}-${AMI_VERSION}.x86_64.gp3" \
  --description "${AMI_DESCRIPTION_STR}"  \
  --query 'ImageId' \
  --output text \
  --instance-id "${BUILDER_ID}" || ( echo FAILED! ; exit 1 )
)"

if [[ ${NEW_IMAGE} == "ami-"* ]]
then
  echo "Registration-process in progress for ${NEW_IMAGE}"
else
  echo "Failed to create image."
fi

# Cleanup the resources created to support the build
BuildCleanup

# Set image-permissions to public if appropriate
if [[ ${AMI_PERMISSIONS:-} == "public" ]]
then
  echo "Setting ${NEW_IMAGE} to public... "

  # Ensure AMI is ready to be made public
  while true
  do
    if [[ $(
        aws ec2 describe-images \
          --image-ids "${NEW_IMAGE}" \
          --query 'Images[].State' \
          --output text
      ) == "available" ]]
    then
      break
    else
      echo "Waiting for ${NEW_IMAGE} to become available. Pausing for 60s"
    fi
    sleep 60
  done

  aws ec2 modify-image-attribute \
    --image-id "${NEW_IMAGE}" \
    --launch-permission "Add=[{Group=all}]" || ( echo "FAILED!" ; exit 1 )
  echo "Success"
fi

# Set deprecation for AMI
DEPRECATE_AT="$(
  date -d @"$(
    date -d '+1 year 00:00:00' '+%s'
  )"
)"

printf "Setting deprecation to %s... " "${DEPRECATE_AT}"
DEPRECATED="$(
  aws ec2 enable-image-deprecation \
    --image-id "${NEW_IMAGE}" \
    --deprecate-at "${DEPRECATE_AT}" \
    --output text
)"

if [[ ${DEPRECATED} == "True" ]]
then
  echo "Done"
else
  echo "Failed"
  exit 1
fi
