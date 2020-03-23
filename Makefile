SHELL := /bin/bash

AWS_EC2_INSTANCE_TYPE ?= t2.xlarge
PACKER_ZIP ?= https://releases.hashicorp.com/packer/1.4.2/packer_1.4.2_linux_amd64.zip
PACKER_LOG ?= '1'
PACKER_NO_COLOR ?= '1'
CHECKPOINT_DISABLE ?= '1'
SPEL_CI ?= false
SPEL_BUILDERS ?= minimal-rhel-7-hvm,minimal-centos-7-hvm
SPEL_DESC_URL ?= https://github.com/plus3it/spel
SPEL_AMIGEN7SOURCE ?= https://github.com/plus3it/AMIgen7.git
SPEL_AMIUTILSOURCE ?= https://github.com/ferricoxide/Lx-GetAMI-Utils.git
SPEL_AWSCLISOURCE ?= https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
SPEL_EPEL7RELEASE ?= https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
SPEL_CUSTOMREPORPM7 ?= https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
SPEL_EPELREPO ?= epel
SPEL_EXTRARPMS ?= https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm,python36
SOURCE_AMI_CENTOS7_HVM ?= ami-090b9dabe1c9f40b3
SOURCE_AMI_RHEL7_HVM ?= ami-0394fe9914b475c53
SSH_INTERFACE ?= public_dns
PIP_URL ?= https://bootstrap.pypa.io/get-pip.py
PYPI_URL ?= https://pypi.org/simple
SECURITY_GROUP_CIDR := $(shell curl 'https://api.ipify.org')/32

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

# Check if $SPEL_PIN_AWSCLI_BUNDLE is not null
ifdef SPEL_PIN_AWSCLI_BUNDLE
AWSCLI_PIN=$(shell grep aws-cli requirements/aws-cli.txt)
ifndef AWSCLI_PIN
$(error AWSCLI_PIN is not set: ${.SHELLSTATUS})
endif

AWSCLI_VERSION:=$(subst aws-cli==,,${AWSCLI_PIN})
SPEL_AWSCLISOURCE := $(shell dirname ${SPEL_AWSCLISOURCE})/awscli-bundle-${AWSCLI_VERSION}.zip
ifndef SPEL_AWSCLISOURCE
$(error SPEL_AWSCLISOURCE is not set: ${SHELLSTATUS})
endif
endif
$(info SPEL_AWSCLISOURCE=${SPEL_AWSCLISOURCE})

all: build

install:
	bash ./build/install.sh -eo pipefail

pre_build: install
	bash ./build/pre_build.sh -eo pipefail

build: pre_build
	bash ./build/build.sh -eo pipefail

post_build:
	bash ./build/post_build.sh -eo pipefail
