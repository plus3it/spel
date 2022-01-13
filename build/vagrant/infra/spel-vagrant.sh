#!/bin/bash
# shellcheck disable=SC2034,SC2154
#  https://www.shellcheck.net/wiki/SC2034 -- <variable> appears unused. Verify use (or export if used externally).
#  https://www.shellcheck.net/wiki/SC2154 -- <variable> is referenced but not assigned...
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

# internal vars
CLONE_DIR=/tmp/spel
S3_BUCKET="s3://$${ARTIFACT_LOCATION}"

if [ "$SPEL_CI" = "true" ]
then
    # artifacts for CI build will be stored in /ci
    # CI build will skip vagrant-cloud post-provisioner
    EXCEPT_STEP="vagrant-cloud"
    S3_BUCKET="$${S3_BUCKET}/ci"

    export EXCEPT_STEP
    export S3_BUCKET
fi

# update PATH
export PATH="$${HOME}/.local/bin:$${PATH}"

# update machine
/usr/bin/cloud-init status --wait
sudo apt-get update && sudo apt-get install -y \
    vagrant \
    python3-pip \
    virtualbox \
    virtualbox-guest-additions-iso

pip3 install awscli --upgrade --user

#install packer
curl -sSL "$PACKER_URL" -o packer.zip
unzip "packer.zip"
chmod +x ./packer
sudo mv packer /usr/local/bin/
packer version

# download spel
git clone "$CODE_REPO" "$CLONE_DIR"
cd "$CLONE_DIR"

if [[ -n "$SOURCE_COMMIT" ]] ; then
    # decide whether to switch to pull request or a branch
    echo "SOURCE_COMMIT = $${SOURCE_COMMIT}"
    if [[ "$SOURCE_COMMIT" =~ ^pr/[0-9]+$ ]]; then
        git fetch origin "pull/$${SOURCE_COMMIT#pr/}/head:$${SOURCE_COMMIT}"
    fi
    git checkout "$${SOURCE_COMMIT}"
fi

# build vagrant box
VAGRANTCLOUD_TOKEN=$(aws ssm get-parameter --name "$SSM_VAGRANTCLOUD_TOKEN" --with-decryption --query Parameter.Value --out text --region us-east-1)
export VAGRANTCLOUD_TOKEN="$VAGRANTCLOUD_TOKEN"

mkdir -p "$${CLONE_DIR}/.spel/$${SPEL_VERSION}/"
export PACKER_LOG=1
export PACKER_LOG_PATH="$${CLONE_DIR}/.spel/$${SPEL_VERSION}/packer.log"

packer build \
  -var "virtualbox_iso_url_centos7=$${ISO_URL_CENTOS7}" \
  -var "virtualbox_vagrantcloud_username=$${VAGRANTCLOUD_USER}" \
  -var "spel_identifier=$${SPEL_IDENTIFIER}" \
  -var "spel_version=$${SPEL_VERSION}" \
  -only "virtualbox-iso.minimal-centos-7" \
  -except "$EXCEPT_STEP" \
  spel/minimal-linux.pkr.hcl

# remove .ova and .box files from artifact location
find "$${CLONE_DIR}/" -type f \( -name '*.box' -o -name '*.ova' \) -print0 | xargs -0 rm -f

# upload artifacts to S3
aws s3 cp --recursive "$${CLONE_DIR}/.spel/" "$${S3_BUCKET}/"
