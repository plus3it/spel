#!/bin/bash
echo "==========STARTING POST_BUILD=========="

if [ "$SPEL_CI" = "true" ]; then
    for BUILDER in ${SPEL_BUILDERS//,/ }; do
        AMI_NAME="${SPEL_IDENTIFIER}-${BUILDER}-${SPEL_VERSION}.x86_64-gp2"
        # shellcheck disable=SC2030,SC2031
        AMI_ID=$(export AWS_DEFAULT_REGION="$AWS_REGION"; aws ec2 describe-images --owners self --filters Name=name,Values="$AMI_NAME" --query 'Images[0].ImageId' --out text --profile "$SPEL_IDENTIFIER")

        if [ "$AMI_ID" != "None" ]; then
            # shellcheck disable=SC2030,SC2031
            SNAPSHOT_ID=$(export AWS_DEFAULT_REGION="$AWS_REGION"; aws ec2 describe-images --image-id "$AMI_ID" --query Images[0].BlockDeviceMappings[0].Ebs.SnapshotId --out text --profile "$SPEL_IDENTIFIER")
            echo "Trying to deregister AMI: ${AMI_NAME}:${AMI_ID} in ${AWS_REGION}"
            # shellcheck disable=SC2030,SC2031,SC2091
            (export AWS_DEFAULT_REGION="$AWS_REGION"; aws ec2 deregister-image --image-id "$AMI_ID" --profile "$SPEL_IDENTIFIER")
            echo "Trying to delete SNAPSHOT: ${SNAPSHOT_ID} in ${AWS_REGION}"
            # shellcheck disable=SC2030,SC2031,SC2091
            (export AWS_DEFAULT_REGION="$AWS_REGION"; aws ec2 delete-snapshot --snapshot-id "$SNAPSHOT_ID" --profile "$SPEL_IDENTIFIER")
        fi
    done
fi

echo "Packer build completed on $(date)"
