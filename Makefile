SHELL := /bin/bash

PACKER_ZIP ?= https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
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

# Check if $SPEL_SSM_ACCESS_KEY is not null
ifdef SPEL_SSM_ACCESS_KEY
SSM_ACCESS_KEY = $(shell aws ssm get-parameters --name ${SPEL_SSM_ACCESS_KEY} --with-decryption --query 'Parameters[0].Value' --out text)
ifeq ("${SSM_ACCESS_KEY}", "None")
$(error SSM_ACCESS_KEY is undefined: ${SHELLSTATUS})
endif
$(shell aws configure set aws_access_key_id ${SSM_ACCESS_KEY} --profile ${SPEL_IDENTIFIER})

SSM_SECRET_KEY = $(shell aws ssm get-parameters --name ${SPEL_SSM_SECRET_KEY} --with-decryption --query 'Parameters[0].Value' --out text)
ifeq ("${SSM_SECRET_KEY}", "None")
$(error SSM_SECRET_KEY is undefined: ${SHELLSTATUS})
endif
$(shell aws configure set aws_secret_access_key ${SSM_SECRET_KEY} --profile ${SPEL_IDENTIFIER})
# Setup the profile credentials
else ifdef AWS_ACCESS_KEY_ID
$(shell aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} --profile ${SPEL_IDENTIFIER})
$(shell aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} --profile ${SPEL_IDENTIFIER})
endif 

# Check if $SPEL_SSM_SESSION_TOKEN is not null
ifdef SPEL_SSM_SESSION_TOKEN
SSM_SESSION_TOKEN_PARAMS = $(shell aws ssm get-parameters --name $SPEL_SSM_SESSION_TOKEN --with-decryption --query 'Parameters[0].Value' --out text)
$(shell aws configure set aws_session_token ${SSM_SESSION_TOKEN_PARAMS} --profile ${SPEL_IDENTIFIER})
endif

$(shell aws configure set region ${AWS_REGION} --profile ${SPEL_IDENTIFIER})

all: build

install:
	bash ./build/install.sh -eo pipefail

pre_build: install
	bash ./build/pre_build.sh -eo pipefail

build: pre_build
	bash ./build/build.sh -eo pipefail
	
post_build:
	bash ./build/post_build.sh -eo pipefail