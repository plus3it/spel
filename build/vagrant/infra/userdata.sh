#!/bin/bash
set -eo

# update machine
sudo apt-get update

# install needed tools
sudo apt-get install awscli vagrant python3-pip -y
sudo apt-get install virtualbox virtualbox-guest-additions-iso -y
pip3 install awscli --upgrade --user

#install packer
sudo apt-get install wget -y
wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
unzip "packer_${PACKER_VERSION}_linux_amd64.zip"
sudo mv packer /usr/local/bin/
packer -v

# download spel
cd /tmp
git clone "$CODE_REPO"
cd spel
git checkout "$SOURCE_COMMIT"
pwd

# setup environment
VAGRANTCLOUD_TOKEN=$(aws ssm get-parameter --name "$SSM_VAGRANTCLOUD_TOKEN" --with-decryption --query Parameter.Value --out text --region us-east-1)
export VAGRANTCLOUD_TOKEN="$VAGRANTCLOUD_TOKEN"

# build vagrant box
mkdir -p "/tmp/spel/.spel/$SPEL_VERSION/"
export PACKER_LOG=1
export PACKER_LOG_PATH="/tmp/spel/.spel/$SPEL_VERSION/packer.log"

packer build -var "vagrantcloud_username=$VAGRANTCLOUD_USER" -var "spel_identifier=$SPEL_IDENTIFIER" -var "spel_version=$SPEL_VERSION" -only "minimal-centos-7-virtualbox" spel/minimal-linux.json

# upload artifacts to S3
aws s3 cp --recursive /tmp/spel/.spel/ "s3://$ARTIFACT_LOCATION/"
