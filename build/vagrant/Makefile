SHELL := /bin/bash
SOURCE_CIDR := $(shell curl -sSL 'https://api.ipify.org')/32

PACKER_VERSION ?= $(shell grep 'FROM hashicorp/packer' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
PACKER_URL ?= https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_arm64.zip
TERRAFORM_VERSION ?= $(shell grep 'FROM hashicorp/terraform' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
TERRAFORM_URL ?= https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip

ISO_URL_CENTOS7_BASE ?= http://mirror.cs.vt.edu/pub/CentOS/7/isos/x86_64
ISO_URL_CENTOS7_FILTER ?= grep -Po '(?<=href=")CentOS-7-x86_64-Minimal-.*\.iso(?=")'
ISO_URL_CENTOS7 ?= $(ISO_URL_CENTOS7_BASE)/$(shell curl -sSL $(ISO_URL_CENTOS7_BASE) | $(ISO_URL_CENTOS7_FILTER))

.PHONY: all install pre_build build post_build
.EXPORT_ALL_VARIABLES:

all: build

install:
	@ if [[ \
		"$(SPEL_CI)" != "true" && \
		-z "$(SPEL_VERSION)" \
	]] ; then \
		echo "[make]: Must set one of SPEL_VERSION, or SPEL_CI=true!" >&2 ;\
		exit 1 ;\
	fi
	@ if [[ \
		"$(SPEL_CI)" == "true" && \
		-n "$(SPEL_VERSION)" \
	]] ; then \
		echo "[make]: Can't set both SPEL_VERSION, and SPEL_CI=true!" >&2 ;\
		exit 1 ;\
	fi
	go mod init spel-vagrant
	go build ./...
	go mod tidy
	curl -sSL $(TERRAFORM_URL) -o terraform.zip
	unzip terraform.zip
	chmod +x terraform
	mv terraform /usr/local/bin/
	terraform version

pre_build: install

build: pre_build
	go test -timeout 60m

post_build:
