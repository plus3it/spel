#!/bin/bash
set -eu -o pipefail

# internal vars
CLONE_DIR=/tmp/spel

if [[ "${SPEL_CI:?}" = "true" ]]
then
    # CI build will skip vagrant-cloud post-provisioner
    EXCEPT_STEP="vagrant-cloud"
    export EXCEPT_STEP
fi

# update PATH
export PATH="${HOME}/.local/bin:${PATH}"

# update machine
/usr/bin/cloud-init status --wait
sudo apt-get update && sudo apt-get install -y \
    vagrant \
    virtualbox \
    virtualbox-guest-additions-iso

#install packer
curl -sSL "${SPEL_PACKER_URL:?}" -o packer.zip
unzip "packer.zip"
chmod +x ./packer
sudo mv packer /usr/local/bin/
packer version

# download spel
git clone "${SPEL_REPO_URL:?}" "$CLONE_DIR"
cd "$CLONE_DIR"

if [[ -n "${SPEL_REPO_COMMIT:-}" ]] ; then
    # decide whether to switch to pull request or a branch
    echo "SOURCE_COMMIT = ${SPEL_REPO_COMMIT}"
    if [[ "$SPEL_REPO_COMMIT" =~ ^pr/[0-9]+$ ]]; then
        git fetch origin "pull/${SPEL_REPO_COMMIT#pr/}/head:${SPEL_REPO_COMMIT}"
    fi
    git checkout "$SPEL_REPO_COMMIT"
fi

# build vagrant box
mkdir -p "${CLONE_DIR}/.spel/${SPEL_VERSION:?}/"
export PACKER_LOG=1
export PACKER_LOG_PATH="${CLONE_DIR}/.spel/${SPEL_VERSION:?}/packer.log"

packer build \
  -var "virtualbox_iso_url_centos7=${VIRTUALBOX_ISO_URL_CENTOS7:?}" \
  -var "virtualbox_vagrantcloud_username=${VAGRANT_CLOUD_USER:?}" \
  -var "spel_identifier=${SPEL_IDENTIFIER:?}" \
  -var "spel_version=${SPEL_VERSION:?}" \
  -only "virtualbox-iso.minimal-centos-7" \
  -except "$EXCEPT_STEP" \
  spel/minimal-linux.pkr.hcl

# remove subdirectories from the artifact location
find "${CLONE_DIR}/.spel/${SPEL_VERSION:?}/" -maxdepth 1 -mindepth 1 -type d -print0 | xargs -0 rm -rf

# remove .ova and .box files from artifact location
find "${CLONE_DIR}/.spel/${SPEL_VERSION:?}/" -type f \( -name '*.box' -o -name '*.ova' \) -print0 | xargs -0 rm -f
