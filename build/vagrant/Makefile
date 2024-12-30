SHELL := /bin/bash

ISO_URL_CENTOS9STREAM_BASE ?= http://mirror.facebook.net/centos-stream/9-stream/BaseOS/x86_64/iso
ISO_URL_CENTOS9STREAM_FILTER ?= grep -Po '(?<=href=")CentOS-Stream-9-latest-x86_64-boot.iso(?=")' | sort -r | head -1

CODEBUILD_SOURCE_REPO_URL ?= https://github.com/plus3it/spel.git
CODEBUILD_SOURCE_VERSION  ?= dependabot/docker/plus3it/master

SPEL_CI ?= false
SPEL_IDENTIFIER ?= spel

export PATH := $(HOME)/bin:$(PATH)

.PHONY: all install pre_build build post_build
.EXPORT_ALL_VARIABLES:

# Set SPEL_VERSION if SPEL_CI is "true"
ifeq ($(SPEL_CI),true)
SPEL_VERSION := $(or $(SPEL_VERSION),$(shell date +%Y.%m.dev%s))
endif

# Exit with error if SPEL_VERSION is not set
ifndef SPEL_VERSION
$(error [make]: Must set one of SPEL_VERSION, or SPEL_CI=true!)
endif

$(info SPEL_IDENTIFIER=$(SPEL_IDENTIFIER))
$(info SPEL_VERSION=$(SPEL_VERSION))

all: build

install:
	$(MAKE) -f ../../Makefile packer/install

build: export PACKER_LOG = 1
build: export PACKER_LOG_PATH = .spel/$(SPEL_VERSION)/packer.build-spel-vagrant.log
build: export PACKER_LOG_DIR = $(dir $(PACKER_LOG_PATH))
build: export PKR_VAR_aws_temporary_security_group_source_cidrs = ["$(shell curl -sSL https://checkip.amazonaws.com)/32"]
build: export PKR_VAR_virtualbox_iso_url_centos9stream ?= $(ISO_URL_CENTOS9STREAM_BASE)/$(shell curl -sSL $(ISO_URL_CENTOS9STREAM_BASE) | $(ISO_URL_CENTOS9STREAM_FILTER))

build:
	mkdir -p "$(PACKER_LOG_DIR)"
	packer init build-spel-vagrant.pkr.hcl
	packer build \
		-var spel_ci=$(SPEL_CI) \
		-var spel_identifier=$(SPEL_IDENTIFIER) \
		-var spel_repo_url=$(CODEBUILD_SOURCE_REPO_URL) \
		-var spel_repo_commit=$(CODEBUILD_SOURCE_VERSION) \
		-var spel_version=$(SPEL_VERSION) \
		-var packer_version=$(PACKER_VERSION) \
		build-spel-vagrant.pkr.hcl
	@if [[ "$(SPEL_CI)" = "true" ]]; then \
		echo "Moving "$(PACKER_LOG_DIR)" to .spel/ci" ;\
		mkdir -p .spel/ci ;\
		rm -rf .spel/ci/$(SPEL_VERSION); \
		mv "$(PACKER_LOG_DIR)" .spel/ci ;\
	fi
