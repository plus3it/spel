SHELL := /bin/bash

PACKER_ZIP ?= https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip
PACKER_LOG ?= '1'
CHECKPOINT_DISABLE ?= '1'
SPEL_CI ?= false
SPEL_BUILDERS ?= amazon-ebs.minimal-rhel-7-hvm,amazon-ebs.minimal-centos-7-hvm,amazon-ebs.minimal-rhel-8-hvm,amazon-ebs.minimal-centos-8stream-hvm
export PATH := $(HOME)/.local/bin:$(PATH)

# The `pre_build`, `build`, and `post_build` targets all use packer in a way that
# supports both Commercial and GovCloud partitions. For GovCloud, the `install`
# target is used to setup an aws profile with credentials. For the Commercial partition,
# the profile is created but the credentials are sourced from the execution environment
# (meaning your workstation or CodeBuild).

# Due to the use of an aws profile, when running interactively, it is required
# to export AWS_PROFILE with a valid profile. For CodeBuild CI, it is set to $SPEL_IDENTIFIER,
# and `make install` will create it.

# Set AWS_DEFAULT_REGION. Do not use "?=" because we *always* want to set this
# in codebuild. We cannot set it in the buildspec because that breaks codebuild
# when building for GovCloud.
AWS_DEFAULT_REGION = $(AWS_REGION)

.PHONY: all install pre_build build post_build
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
PACKER_LOG_PATH = .spel/$(SPEL_VERSION)/packer.log
endif

all: build

install: PACKER_VERSION ?= $(shell grep 'FROM hashicorp/packer' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
install:
	bash -eo pipefail ./build/install.sh

# The profile is used only by the `pre_build`, `build`, and `post_build` targets
pre_build build post_build: export AWS_PROFILE ?= $(SPEL_IDENTIFIER)

pre_build:
	bash -eo pipefail ./build/pre_build.sh

build: PKR_VAR_aws_temporary_security_group_source_cidrs = ["$(shell curl -sSL https://api.ipify.org)/32"]
build: pre_build
	bash ./build/build.sh

post_build:
	bash -eo pipefail ./build/post_build.sh
