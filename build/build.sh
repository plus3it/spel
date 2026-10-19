#!/bin/bash
# Do not use `set -e`, as we handle the errexit in the script
set -u -o pipefail

# shellcheck source=build/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "==========STARTING BUILD=========="

# Builds are idempotent, so a failed job can be re-run. For each builder, check
# for an existing AMI in the build region:
#   * none                    -> build it
#   * public                  -> skip it, it is already published
#   * private, validated      -> skip it, it already passed the tests
#   * private, not validated  -> leftover from a failed attempt, deregister and rebuild
# Setting PKR_VAR_aws_force_deregister=true rebuilds validated AMIs, but will not
# replace a public AMI. Deregister published AMIs from all regions first.
FORCE="${PKR_VAR_aws_force_deregister:-false}"
PENDING_BUILDS=()

for BUILDER in ${SPEL_BUILDERS//,/ }; do
    AMI_NAME=$(spel_ami_name "$BUILDER")
    AMI_ID=$(spel_describe_image "${AWS_REGION:?}" "$AMI_NAME" "ImageId") || exit 1

    if [[ "$AMI_ID" == "None" ]]; then
        PENDING_BUILDS+=("$BUILDER")
        continue
    fi

    PUBLIC=$(spel_describe_image "$AWS_REGION" "$AMI_NAME" "Public") || exit 1
    VALIDATED=$(spel_image_tag "$AWS_REGION" "$AMI_NAME" "$SPEL_TAG_VALIDATED") || exit 1

    if [[ "$PUBLIC" == "True" ]]; then
        if [[ "$FORCE" == "true" ]]; then
            echo "ERROR: Cannot force rebuild of public AMI ${AMI_NAME}:${AMI_ID}. Deregister it from all regions first."
            exit 1
        fi
        echo "Skipping build, AMI is already published: ${AMI_NAME}:${AMI_ID}"
    elif [[ "$VALIDATED" == "true" && "$FORCE" != "true" ]]; then
        echo "Skipping build, AMI already passed validation: ${AMI_NAME}:${AMI_ID}"
    else
        spel_deregister_image "$AWS_REGION" "$AMI_NAME" || exit 1
        PENDING_BUILDS+=("$BUILDER")
    fi
done

if [[ ${#PENDING_BUILDS[@]} -eq 0 ]]; then
    echo "All AMIs already exist and passed validation, nothing to build"
    exit 0
fi

PENDING_BUILDERS=$(IFS=, ; echo "${PENDING_BUILDS[*]}")
echo "Building packer template, spel/minimal-linux.pkr.hcl: ${PENDING_BUILDERS}"

packer build \
    -only "$PENDING_BUILDERS" \
    -var "spel_identifier=${SPEL_IDENTIFIER:?}" \
    -var "spel_version=${SPEL_VERSION:?}" \
    spel/minimal-linux.pkr.hcl

BUILDEXIT=$?

FAILED_BUILDS=()
FAILED_TESTS=()

# Test each AMI separately, so a pass or failure is attributed to a specific AMI
for BUILDER in "${PENDING_BUILDS[@]}"; do
    AMI_NAME=$(spel_ami_name "$BUILDER")
    BUILDER_AMI=$(spel_describe_image "$AWS_REGION" "$AMI_NAME" "ImageId") || exit 1

    if [[ "$BUILDER_AMI" == "None" ]]; then
        FAILED_BUILDS+=("$BUILDER")
        continue
    fi

    BUILDER_ENV="${BUILDER//[.-]/_}"
    export "$BUILDER_ENV"="$BUILDER_AMI"

    echo "Testing build: ${BUILDER}, ${AMI_NAME}:${BUILDER_AMI}"
    if packer build \
        -only "${BUILDER//amazon-ebssurrogate./amazon-ebs.}" \
        -var "spel_identifier=${SPEL_IDENTIFIER:?}" \
        -var "spel_version=${SPEL_VERSION:?}" \
        tests/minimal-linux.pkr.hcl
    then
        echo "Marking AMI as validated: ${AMI_NAME}:${BUILDER_AMI}"
        aws ec2 create-tags \
            --region "$AWS_REGION" \
            --resources "$BUILDER_AMI" \
            --tags "Key=${SPEL_TAG_VALIDATED},Value=true" \
            || FAILED_TESTS+=("$BUILDER")
    else
        FAILED_TESTS+=("$BUILDER")
        # The AMI is still private and only exists in the build region, so it
        # is safe to remove it. This lets the job be re-run without cleanup.
        if [[ "${SPEL_KEEP_FAILED:-false}" != "true" ]]; then
            spel_deregister_image "$AWS_REGION" "$AMI_NAME"
        fi
    fi
done

if [[ $BUILDEXIT -ne 0 ]]; then
    FAILED_BUILDERS=$(IFS=, ; echo "${FAILED_BUILDS[*]}")
    echo "ERROR: Failed builds: ${FAILED_BUILDERS}"
    echo "ERROR: Build failed. Scroll up past the test to see the packer error and review the build logs."
    exit $BUILDEXIT
fi

if [[ ${#FAILED_TESTS[@]} -ne 0 ]]; then
    FAILED_TESTERS=$(IFS=, ; echo "${FAILED_TESTS[*]}")
    echo "ERROR: Failed tests: ${FAILED_TESTERS}"
    echo "ERROR: Test failed. Review the test logs for the error."
    exit 1
fi
