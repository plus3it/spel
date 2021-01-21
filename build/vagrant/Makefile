SHELL := /bin/bash
SOURCE_CIDR := $(shell curl 'https://api.ipify.org')/32

PACKER_VERSION ?= $(shell grep 'FROM hashicorp/packer' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
PACKER_URL ?= https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip
TERRAFORM_VERSION ?= $(shell grep 'FROM hashicorp/terraform' Dockerfile 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2> /dev/null)
TERRAFORM_URL ?= https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip

.PHONY: all install pre_build build post_build
.EXPORT_ALL_VARIABLES:

all: build

install:
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
