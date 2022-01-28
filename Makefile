SHELL := /bin/bash

PACKER_ZIP ?= https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip
PACKER_LOG ?= '1'
PACKER_LOG_PATH = .spel/$(SPEL_VERSION)/packer.log
CHECKPOINT_DISABLE ?= '1'
SPEL_CI ?= false
SPEL_BUILDERS ?= amazon-ebs.minimal-rhel-7-hvm,amazon-ebs.minimal-centos-7-hvm,amazon-ebs.minimal-rhel-8-hvm,amazon-ebs.minimal-centos-8stream-hvm
export PATH := $(HOME)/bin:$(PATH)

# The `pre_build`, `build`, and `post_build` targets all use packer in a way that
# supports both Commercial and GovCloud partitions. For GovCloud, the `install`
# target is used to setup an aws profile with credentials retrieved from SSM. For
# the Commercial partition, the profile is created but the credentials are sourced
# from the execution environment (meaning your workstation or CodeBuild).

# Due to the use of an aws profile, when running interactively, it is required
# to export AWS_PROFILE with a valid profile. For CodeBuild CI, it is set to $SPEL_IDENTIFIER,
# and `make install` will create it.

# For GovCloud, set the ami filters to find the correct AMIs. The default values
# otherwise work fine for all RedHat build (GovCloud or otherwise), and for all
# builds in the Commercial partition.
ifeq ($(PKR_VAR_aws_region),us-gov-west-1)
PKR_VAR_aws_source_ami_filter_centos7_hvm = {name = "*-Recovery (No-LVM)-ACB-CentOS7-HVM-SRIOV_ENA", owners = ["039368651566"]}
PKR_VAR_aws_source_ami_filter_centos8stream_hvm = {name = "spel-bootstrap-centos-8stream-hvm-*.x86_64-gp2", owners = ["039368651566"]}
endif

.PHONY: all install pre_build build post_build docs
.EXPORT_ALL_VARIABLES:

$(info SPEL_IDENTIFIER=$(SPEL_IDENTIFIER))
$(info SPEL_VERSION=$(SPEL_VERSION))

ifndef SPEL_IDENTIFIER
$(error SPEL_IDENTIFIER is not set)
endif

ifndef SPEL_VERSION
$(error SPEL_VERSION is not set)
else
$(shell mkdir -p ".spel/$(SPEL_VERSION)")
endif

all: build

docs/lint:
	$(MAKE) -f Makefile.tardigrade-ci docs/lint

docs/generate:
	$(MAKE) -f Makefile.tardigrade-ci docs/generate

install:
	$(MAKE) -f Makefile.tardigrade-ci packer/install
	bash -eo pipefail ./build/install.sh

# The profile and region envs are used only by the `pre_build`, `build`, and `post_build`
# targets. For the region targets, do not use "?=" because we *always* want to
# override this in codebuild. We cannot set these in the buildspec because that
# breaks codebuild when building for GovCloud.
pre_build build post_build: export AWS_PROFILE ?= $(SPEL_IDENTIFIER)
pre_build build post_build: export AWS_DEFAULT_REGION := $(or $(PKR_VAR_aws_region),$(AWS_REGION))
pre_build build post_build: export AWS_REGION := $(or $(PKR_VAR_aws_region),$(AWS_REGION))

# Set the source security group cidr
pre_build build post_build: export PKR_VAR_aws_temporary_security_group_source_cidrs = ["$(shell curl -sSL https://api.ipify.org)/32"]

pre_build:
	bash ./build/pre_build.sh

build: pre_build
	bash ./build/build.sh

post_build:
	bash ./build/post_build.sh
