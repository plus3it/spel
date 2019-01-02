#!/bin/bash
echo "==========STARTING INSTALL========="
echo "Installing unzip............"
apt -y install unzip
echo "Installing packer..."
echo "$PWD"
curl -L "$PACKER_ZIP" -o packer.zip && unzip packer.zip
