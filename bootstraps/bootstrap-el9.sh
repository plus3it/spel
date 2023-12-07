#!/bin/bash
AWS_REGION="${SPEL_AWS_REGION:-}"
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
    CONTROL_MAC="$(
      "${CURL_CMD[@]}/meta-data/network/interfaces/macs"
    )"
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


##################
## Main Program ##
##################

# Cobble together the curel command and base options-set
UseCurlCmd

# Set AWS_REGION as necessary
if [[ -z ${AWS_REGION:-} ]]
then
  AWS_REGION="$( "${CURL_CMD[@]}/meta-data/placement/region" )"
fi  

RUN_SEC_GRP="$( CreateBuilderSg )"

# Compute build-subnet as necessary
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
    -e 's#FSTYP_SUBST#xfs#' \
    -e 's#BOOTLBL_SUBST#boot_disk#' \
    -e 's#UEFILBL_SUBST#UEFI_DISK#' \
    -e 's#BOOTDEVSZ_SUBST#512#' \
    -e 's#UEFIDEVSZ_SUBST#96#' \
    -e 's#VGNAME_SUBST#RootVG#' \
   builder-userData.tpl > builder-userData.runtime

LAUNCH_CMD=(
  aws ec2 run-instances
  --block-device-mappings "'DeviceName=/dev/sda1,Ebs={VolumeType=gp3}'" "'DeviceName=/dev/sdf,Ebs={VolumeType=gp2,VolumeSize=25}'"
  --image-id ami-034cb23b05c0d2a84
  --instance-type "${INSTANCE_TYPE}"
  --output text
  --query "'Instances[].InstanceId'"
  --region "${AWS_REGION}"
  --security-group-ids "${RUN_SEC_GRP}"
  --subnet-id "${BUILD_SUBNET}"
  --tag-specifications "'ResourceType=instance,Tags=[{Key=Name,Value=Packer Chroot-build}]'"
  --user-data file://builder-userData.runtime
)

echo "${LAUNCH_CMD[@]}"

#aws ec2 delete-security-group --group-id "${RUN_SEC_GRP}"
