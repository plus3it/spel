SHELL := /bin/bash

PACKER_LOG = '1'

PACKER_VERSION ?= $(shell grep 'FROM hashicorp/packer' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
PACKER_URL ?= https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip

ISO_URL_CENTOS7_BASE ?= http://mirror.cs.vt.edu/pub/CentOS/7/isos/x86_64
ISO_URL_CENTOS7_FILTER ?= grep -Po '(?<=href=")CentOS-7-x86_64-Minimal-.*\.iso(?=")'

CODEBUILD_SOURCE_REPO_URL ?= https://github.com/plus3it/spel.git
CODEBUILD_SOURCE_VERSION  ?= master

SPEL_IDENTIFIER ?= spel

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
	if ! hash packer 2> /dev/null; then \
		curl -sSL $(PACKER_URL) -o packer.zip ;\
		unzip packer.zip ;\
		chmod +x packer ;\
		mv packer /usr/local/bin/ ;\
	fi
	packer version

build: export PACKER_LOG_PATH = .spel/$(SPEL_VERSION)/packer.build-spel-vagrant.log
build: export PACKER_LOG_DIR = $(dir $(PACKER_LOG_PATH))
build: export PKR_VAR_aws_temporary_security_group_source_cidrs = ["$(shell curl -sSL https://api.ipify.org)/32"]
build: export PKR_VAR_virtualbox_iso_url_centos7 ?= $(ISO_URL_CENTOS7_BASE)/$(shell curl -sSL $(ISO_URL_CENTOS7_BASE) | $(ISO_URL_CENTOS7_FILTER))

build:
	mkdir -p "$(PACKER_LOG_DIR)"
	packer build \
		-var spel_ci=$(SPEL_CI) \
		-var spel_identifier=$(SPEL_IDENTIFIER) \
		-var spel_packer_url=$(PACKER_URL) \
		-var spel_repo_url=$(CODEBUILD_SOURCE_REPO_URL) \
		-var spel_repo_commit=$(CODEBUILD_SOURCE_VERSION) \
		-var spel_version=$(SPEL_VERSION) \
		build-spel-vagrant.pkr.hcl
	@if [[ "$(SPEL_CI)" = "true" ]]; then \
		echo "Moving "$(PACKER_LOG_DIR)" to .spel/ci" ;\
		mkdir -p .spel/ci ;\
		mv "$(PACKER_LOG_DIR)" .spel/ci ;\
	fi
