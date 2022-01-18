#!/bin/bash
set -eu -o pipefail

echo "==========STARTING POST_BUILD=========="

if [ "${SPEL_CI:?}" = "true" ]; then
    for BUILDER in ${SPEL_BUILDERS//,/ }; do
        BUILD_NAME="${BUILDER//*./}"
        AMI_NAME="${SPEL_IDENTIFIER}-${BUILD_NAME}-${SPEL_VERSION}.x86_64-gp2"
        AMI_ID=$(aws ec2 describe-images --owners self --filters Name=name,Values="$AMI_NAME" --query 'Images[0].ImageId' --out text)

        if [ "$AMI_ID" != "None" ]; then
            SNAPSHOT_ID=$(aws ec2 describe-images --image-id "$AMI_ID" --query Images[0].BlockDeviceMappings[0].Ebs.SnapshotId --out text)
            echo "Trying to deregister AMI: ${AMI_NAME}:${AMI_ID} in ${AWS_REGION}"
            aws ec2 deregister-image --image-id "$AMI_ID"
            echo "Trying to delete SNAPSHOT: ${SNAPSHOT_ID} in ${AWS_REGION}"
            aws ec2 delete-snapshot --snapshot-id "$SNAPSHOT_ID"
        fi
    done
fi

echo "Packer build completed on $(date)"
