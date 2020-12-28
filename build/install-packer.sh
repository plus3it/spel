#!/usr/bin/env bash

set -e

if [[ "$(whoami)" != "root" ]]; then
  echo "ERROR:  Must be run as root (e.g. 'sudo ./install-packer.sh')" 1>&2
  exit 1
fi

curl -s https://releases.hashicorp.com/packer/1.6.6/packer_1.6.6_linux_amd64.zip > packer.zip
unzip packer.zip
mv packer /usr/local/bin/packer
chown root:root /usr/local/bin/packer
chmod u=rwx,g=rwx,o=rx /usr/local/bin/packer

