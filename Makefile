SHELL := /bin/bash

AWS_EC2_INSTANCE_TYPE ?= t3.2xlarge
PACKER_VERSION ?= $(shell grep 'FROM hashicorp/packer' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
PACKER_ZIP ?= https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip
PACKER_LOG ?= '1'
PACKER_NO_COLOR ?= '1'
CHECKPOINT_DISABLE ?= '1'
SPEL_CI ?= false
SPEL_BUILDERS ?= minimal-rhel-7-hvm,minimal-centos-7-hvm,minimal-rhel-8-hvm,minimal-centos-8-hvm
SPEL_DESC_URL ?= https://github.com/plus3it/spel
SPEL_AMIGEN7SOURCE ?= https://github.com/plus3it/AMIgen7.git
SPEL_AMIGEN7BRANCH ?= master
SPEL_AMIGEN7REPOSRC ?= https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
SPEL_AMIGEN8SOURCE ?= https://github.com/plus3it/AMIgen8.git
SPEL_AMIGEN8BRANCH ?= master
SPEL_AMIGEN8REPOSRC ?= https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
SPEL_AMIUTILSOURCE ?= https://github.com/ferricoxide/Lx-GetAMI-Utils.git
SPEL_AWSCLIV1SOURCE ?= https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
SPEL_AWSCLIV2SOURCE ?= https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
SPEL_AMIGENBUILDDEV ?= /dev/nvme0n1
SPEL_EPEL7RELEASE ?= https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
SPEL_EPEL8RELEASE ?= https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
SPEL_EPELREPO ?= epel
SPEL_EXTRARPMS ?= https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm,python36
SOURCE_AMI_CENTOS7_HVM ?= ami-0fe72edf3b2f0c9e6
SOURCE_AMI_RHEL7_HVM ?= ami-073955d8665a7a9e7
SOURCE_AMI_CENTOS8_HVM ?= ami-05d7cb15bfbf13b6d
SOURCE_AMI_RHEL8_HVM ?= ami-03a454637e4aa453d
SSH_INTERFACE ?= public_dns
PIP_URL ?= https://bootstrap.pypa.io/get-pip.py
PYPI_URL ?= https://pypi.org/simple
SECURITY_GROUP_CIDR := $(shell curl -sSL 'https://api.ipify.org')/32

.PHONY: all install pre_build build post_build
.EXPORT_ALL_VARIABLES:

$(info SPEL_IDENTIFIER=${SPEL_IDENTIFIER})
$(info SPEL_VERSION=${SPEL_VERSION})

ifndef SPEL_IDENTIFIER
$(error SPEL_IDENTIFIER is not set)
endif

ifndef SPEL_VERSION
$(error SPEL_VERSION is not set)
else
$(shell mkdir -p ".spel/${SPEL_VERSION}")
PACKER_LOG_PATH := .spel/${SPEL_VERSION}/packer.log
endif

$(info SPEL_AWSCLIV1SOURCE=${SPEL_AWSCLIV1SOURCE})
$(info SPEL_AWSCLIV2SOURCE=${SPEL_AWSCLIV2SOURCE})

all: build

install:
	bash -eo pipefail ./build/install.sh

pre_build: install
	bash -eo pipefail ./build/pre_build.sh

build: pre_build
	bash -eo pipefail ./build/build.sh

post_build:
	bash -eo pipefail ./build/post_build.sh
