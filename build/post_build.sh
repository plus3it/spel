#!/bin/bash
echo "==========STARTING POST_BUILD=========="

if [ "$SPEL_CI" = "true" ]; then
    for BUILDER in ${SPEL_BUILDERS//,/ }; do
        AMI_NAME="$SPEL_IDENTIFIER-$BUILDER-$SPEL_VERSION.x86_64-gp2"
        # shellcheck disable=SC2030,SC2031
        AMI_ID=$(export AWS_DEFAULT_REGION="$AWS_REGION"; aws ec2 describe-images --filters Name=name,Values="$AMI_NAME" --query 'Images[0].ImageId' --out text --profile "$SPEL_IDENTIFIER")
        echo "Trying to deregister: $AMI_NAME:$AMI_ID in $AWS_REGION"
        # shellcheck disable=SC2030,SC2031,SC2091
        $(export AWS_DEFAULT_REGION="$AWS_REGION"; test "$AMI_ID" != "None" && aws ec2 deregister-image --image-id "$AMI_ID" --profile "$SPEL_IDENTIFIER")
    done
fi

echo "Packer build completed on $(date)"
