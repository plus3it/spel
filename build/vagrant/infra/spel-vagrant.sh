#!/bin/bash
set -e

# terraform template vars
ARTIFACT_LOCATION=${artifact_location}
CODE_REPO=${code_repo}
ISO_URL_CENTOS7=${iso_url_centos7}
PACKER_URL=${packer_url}
SOURCE_COMMIT=${source_commit}
SPEL_CI=${spel_ci}
SPEL_IDENTIFIER=${spel_identifier}
SPEL_VERSION=${spel_version}
SSM_VAGRANTCLOUD_TOKEN=${ssm_vagrantcloud_token}
VAGRANTCLOUD_USER=${vagrantcloud_user}

# update machine
sleep 120

sudo apt-get update && sudo apt-get install -y \
awscli \
vagrant \
python3-pip \
virtualbox \
virtualbox-guest-additions-iso

pip3 install awscli --upgrade --user

#install packer
curl -sSL "$${PACKER_URL}" -o packer.zip
unzip "packer.zip"
chmod +x ./packer
sudo mv packer /usr/local/bin/
packer version

# download spel
cd /tmp
git clone "$${CODE_REPO}"
cd spel

if [[ -n "$${SOURCE_COMMIT}" ]] ; then
    # decide whether to switch to pull request or a branch
    echo "SOURCE_COMMIT = $${SOURCE_COMMIT}"
    if [[ "$${SOURCE_COMMIT}" =~ ^pr/[0-9]+$ ]]; then
        git fetch origin "pull/$${SOURCE_COMMIT#pr/}/head:$${SOURCE_COMMIT}"
    fi
    git checkout "$${SOURCE_COMMIT}"
fi

pwd

# setup environment
VAGRANTCLOUD_TOKEN=$(aws ssm get-parameter --name "$${SSM_VAGRANTCLOUD_TOKEN}" --with-decryption --query Parameter.Value --out text --region us-east-1)
export VAGRANTCLOUD_TOKEN="$${VAGRANTCLOUD_TOKEN}"

# build vagrant box
mkdir -p "/tmp/spel/.spel/$${SPEL_VERSION}/"
export PACKER_LOG=1
export PACKER_LOG_PATH="/tmp/spel/.spel/$${SPEL_VERSION}/packer.log"

# setup s3 bucket to store artifacts
# artifacts for CI build will be stored in /ci
S3_BUCKET="s3://$${ARTIFACT_LOCATION}"

if [ "$${SPEL_CI}" = "true" ]
then
    EXCEPT_STEP="vagrant-cloud"
    S3_BUCKET="$${S3_BUCKET}/ci"

    export EXCEPT_STEP
    export S3_BUCKET
fi

packer build \
  -var "iso_url_centos7=$${ISO_URL_CENTOS7}" \
  -var "vagrantcloud_username=$${VAGRANTCLOUD_USER}" \
  -var "spel_identifier=$${SPEL_IDENTIFIER}" \
  -var "spel_version=$${SPEL_VERSION}" \
  -only "minimal-centos-7-virtualbox" \
  -except "$${EXCEPT_STEP}" \
  spel/minimal-linux.json

# remove .ova and .box files from artifact location
find /tmp/spel/ -type f \( -name '*.box' -o -name '*.ova' \) -print0 | xargs -0 rm -f

# upload artifacts to S3
aws s3 cp --recursive /tmp/spel/.spel/ "$${S3_BUCKET}/"
