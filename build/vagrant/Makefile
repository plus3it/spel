SHELL := /bin/bash

SOURCE_CIDR := $(shell curl 'https://api.ipify.org')/32
TERRAFORM_VERSION ?= 0.11.11

.PHONY: all install pre_build build post_build
.EXPORT_ALL_VARIABLES:

all: build

install:
	go mod init spel-vagrant
	go build ./...
	go mod tidy
	curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	mv terraform /usr/local/bin/
	terraform -v

pre_build: install

build: pre_build
	go test -timeout 60m

post_build:
