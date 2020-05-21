#!/bin/bash
echo "==========STARTING PRE_BUILD=========="
echo "Validating packer template, spel/minimal-linux.json"

AWS_PROFILE="$SPEL_IDENTIFIER" ./packer validate \
  -only "$SPEL_BUILDERS" \
  -var "ami_groups=$AMI_GROUPS" \
  -var "ami_regions=$AMI_REGIONS" \
  -var "ami_users=$AMI_USERS" \
  -var "pip_url=$PIP_URL" \
  -var "pypi_url=$PYPI_URL" \
  -var "aws_region=$AWS_REGION" \
  -var "aws_ec2_instance_type=$AWS_EC2_INSTANCE_TYPE" \
  -var "security_group_cidrs=$SECURITY_GROUP_CIDR" \
  -var "spel_desc_url=$SPEL_DESC_URL" \
  -var "spel_amigen7source=$SPEL_AMIGEN7SOURCE" \
  -var "spel_amigen7branch=$SPEL_AMIGEN7BRANCH" \
  -var "spel_amigen8source=$SPEL_AMIGEN8SOURCE" \
  -var "spel_amigen8branch=$SPEL_AMIGEN8BRANCH" \
  -var "spel_amiutilsource=$SPEL_AMIUTILSOURCE" \
  -var "spel_awsclisource=$SPEL_AWSCLISOURCE" \
  -var "spel_customreporpm7=$SPEL_CUSTOMREPORPM7" \
  -var "spel_customreponame7=$SPEL_CUSTOMREPONAME7" \
  -var "spel_devnode=$SPEL_DEVNODE" \
  -var "spel_disablefips=$SPEL_DISABLEFIPS" \
  -var "spel_epel7release=$SPEL_EPEL7RELEASE" \
  -var "spel_epelrepo=$SPEL_EPELREPO" \
  -var "spel_extrarpms=$SPEL_EXTRARPMS" \
  -var "spel_identifier=$SPEL_IDENTIFIER" \
  -var "spel_version=$SPEL_VERSION" \
  -var "source_ami_centos7_hvm=$SOURCE_AMI_CENTOS7_HVM" \
  -var "source_ami_rhel7_hvm=$SOURCE_AMI_RHEL7_HVM" \
  -var "source_ami_centos8_hvm=$SOURCE_AMI_CENTOS8_HVM" \
  -var "source_ami_rhel8_hvm=$SOURCE_AMI_RHEL8_HVM" \
  -var "ssh_interface=$SSH_INTERFACE" \
  -var "subnet_id=$SUBNET_ID" \
  spel/minimal-linux.json
