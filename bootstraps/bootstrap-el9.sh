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
AMI_IDENTIFIER="${SPEL_IDENTIFIER:-spel-minimal-rhel-9-hvm}"
AMI_VERSION="${SPEL_VERSION:-0.0.0}"
AWS_REGION="${SPEL_AWS_REGION:-}"
BOOTSTRAP_AMI="${AMIGEN9_BOOTSTRAP_AMI:-}"
BUILD_SUBNET="${SPEL_SUBNET:-}"
BUILD_VPC_ID="${SPEL_VPC_ID:-}"
CURL_CMD=()
INSTANCE_TYPE="${SPEL_INSTANCE_TYPE:-t3.large}"
METADATA_URL="http://169.254.169.254"

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

  echo "${RUN_SEC_GRP}"
  return 1
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
  aws ec2 terminate-instances \
    --query 'TerminatingInstances[].CurrentState.Name' \
    --instance-ids "${BUILDER_ID}" || ( echo "FAILED!" ; exit 1 )

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


##################
## Main Program ##
##################

# Cobble together the curl command and base options-set
UseCurlCmd

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

RUN_SEC_GRP="$( CreateBuilderSg )"

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
   builder-userData.tpl > builder-userData.runtime

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
    --user-data file://builder-userData.runtime
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
    echo "${BUILDER_ID} still has not stopped: checking again in 60 seconds"
  fi
  sleep 60
done

# Detach volumes
printf "Detaching %s from %s... " "${BUILDER_ROOT}" "${BUILDER_ID}"
aws ec2 detach-volume \
  --volume-id "${BUILDER_ROOT}" \
  --query 'State' \
  --instance-id "${BUILDER_ID}" || ( echo FAILED! ; exit 1 )

printf "Detaching %s from %s... " "${BUILDER_CHROOT}" "${BUILDER_ID}"
aws ec2 detach-volume \
  --volume-id "${BUILDER_CHROOT}" \
  --query 'State' \
  --instance-id "${BUILDER_ID}" || ( echo FAILED! ; exit 1 )

# Attach chroot-disk as boot-disk
printf "Attaching %s to %s... " "${BUILDER_CHROOT}" "${BUILDER_ID}"
aws ec2 attach-volume \
  --volume-id "${BUILDER_CHROOT}" \
  --device /dev/sda1 \
  --query 'State' \
  --instance-id "${BUILDER_ID}" || ( echo FAILED! ; exit 1 )

# Create image from EC2
echo "Registering image from ${BUILDER_ID}... "
aws ec2 create-image \
  --name "${AMI_IDENTIFIER}-${AMI_VERSION}.x86_64.gp3" \
  --description "${AMI_DESCRIPTION_STR}"  \
  --instance-id "${BUILDER_ID}" || ( echo FAILED! ; exit 1 )

# Cleanup the resources created to support the build
BuildCleanup
