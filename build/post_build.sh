#!/bin/bash
set -eu -o pipefail

echo "==========STARTING POST_BUILD=========="

if [[ "${SPEL_CI:?}" = "true" ]]; then
    for BUILDER in ${SPEL_BUILDERS//,/ }; do
        BUILD_NAME="${BUILDER//*./}"
        AMI_NAME="${SPEL_IDENTIFIER}-${BUILD_NAME}-${SPEL_VERSION}.x86_64-gp3"
        AMI_ID=$(aws ec2 describe-images --owners self --filters Name=name,Values="$AMI_NAME" --query 'Images[0].ImageId' --out text)

        if [[ "$AMI_ID" != "None" ]]; then
            echo "Trying to deregister AMI: ${AMI_NAME}:${AMI_ID} in ${AWS_REGION}"
            aws ec2 deregister-image --image-id "$AMI_ID" --delete-associated-snapshots
        fi
    done
fi

echo "Packer build completed on $(date)"
