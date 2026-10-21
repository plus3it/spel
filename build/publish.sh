#!/bin/bash
set -eu -o pipefail
shopt -s inherit_errexit

# shellcheck source=build/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "==========STARTING PUBLISH=========="

# Publishes validated AMIs from the build region:
#   1. Copies the AMI to each region in SPEL_AMI_REGIONS
#   2. Waits for all copies to become available
#   3. Applies the deprecation time of the source AMI to the copies
#   4. Grants launch permissions in SPEL_AMI_GROUPS and SPEL_AMI_USERS, in all regions
# Launch permissions are granted last, so a failure leaves every AMI private.
# Every step is idempotent. Re-run the script to resume after a failure.
#
# Inputs (JSON-encoded lists):
#   SPEL_AMI_REGIONS  regions to copy the AMIs to, e.g. ["us-east-1", "us-west-2"]
#   SPEL_AMI_GROUPS   groups to grant launch permissions, e.g. ["all"] for public
#   SPEL_AMI_USERS    account IDs to grant launch permissions

SOURCE_REGION="${AWS_REGION:?}"
AMI_REGIONS="${SPEL_AMI_REGIONS:-[]}"
AMI_GROUPS="${SPEL_AMI_GROUPS:-[]}"
AMI_USERS="${SPEL_AMI_USERS:-[]}"
PUBLISH_TIMEOUT="${SPEL_PUBLISH_TIMEOUT:-3600}"
IMAGES_FILE="${SPEL_IMAGES_FILE:-.spel/${SPEL_VERSION:?}/images.json}"

TARGET_REGIONS_LIST=$(jq -r --arg source "$SOURCE_REGION" '(. // [])[] | select(. != $source)' <<< "$AMI_REGIONS")
mapfile -t TARGET_REGIONS <<< "$TARGET_REGIONS_LIST"
[[ -z "${TARGET_REGIONS[0]}" ]] && TARGET_REGIONS=()

LAUNCH_PERMISSION=$(jq -cn \
    --argjson groups "$AMI_GROUPS" \
    --argjson users "$AMI_USERS" \
    '{Add: ([$groups[] | {Group: .}] + [$users[] | {UserId: .}])}')

# Prints the ID of the copy of $SOURCE_AMI in the region, starting the copy if needed.
# A private copy of a different source AMI is stale, and is replaced.
copy_image() {
    local region="$1" copy_id copy_source copy_state description_args=()

    copy_id=$(spel_describe_image "$region" "$AMI_NAME" "ImageId")
    if [[ "$copy_id" != "None" ]]; then
        copy_source=$(spel_image_tag "$region" "$AMI_NAME" "$SPEL_TAG_SOURCE_IMAGE_ID")
        copy_state=$(spel_describe_image "$region" "$AMI_NAME" "State")
        if [[ "$copy_source" == "$SOURCE_AMI" && "$copy_state" =~ ^(pending|available)$ ]]; then
            echo "Found existing copy in ${region}: ${AMI_NAME}:${copy_id} (${copy_state})" >&2
            echo "$copy_id"
            return 0
        fi
        echo "Replacing stale copy in ${region}: ${AMI_NAME}:${copy_id} (source: ${copy_source}, state: ${copy_state})" >&2
        spel_deregister_image "$region" "$AMI_NAME" >&2
    fi

    [[ "$DESCRIPTION" != "None" ]] && description_args=(--description "$DESCRIPTION")

    echo "Copying ${AMI_NAME}:${SOURCE_AMI} from ${SOURCE_REGION} to ${region}" >&2
    aws ec2 copy-image \
        --region "$region" \
        --source-region "$SOURCE_REGION" \
        --source-image-id "$SOURCE_AMI" \
        --name "$AMI_NAME" \
        "${description_args[@]}" \
        --copy-image-tags \
        --tag-specifications "$(jq -cn \
            --arg key "$SPEL_TAG_SOURCE_IMAGE_ID" \
            --arg value "$SOURCE_AMI" \
            '[{ResourceType: "image", Tags: [{Key: $key, Value: $value}]}]')" \
        --query ImageId \
        --output text
}

# Waits for the AMI to become available, until the publish deadline
wait_image() {
    local region="$1" ami_id="$2" state

    while true; do
        state=$(aws ec2 describe-images \
            --region "$region" \
            --image-ids "$ami_id" \
            --query 'Images[0].State' \
            --output text)
        case "$state" in
            available)
                echo "AMI is available in ${region}: ${AMI_NAME}:${ami_id}"
                return 0
                ;;
            pending)
                if [[ $SECONDS -ge $DEADLINE ]]; then
                    echo "ERROR: Timed out waiting for AMI in ${region}: ${AMI_NAME}:${ami_id}"
                    return 1
                fi
                sleep 30
                ;;
            *)
                echo "ERROR: AMI in ${region} is in state '${state}': ${AMI_NAME}:${ami_id}"
                return 1
                ;;
        esac
    done
}

IMAGES=()
DEADLINE=$((SECONDS + PUBLISH_TIMEOUT))

for BUILDER in ${SPEL_BUILDERS//,/ }; do
    AMI_NAME=$(spel_ami_name "$BUILDER")
    SOURCE_AMI=$(spel_describe_image "$SOURCE_REGION" "$AMI_NAME" "ImageId")

    if [[ "$SOURCE_AMI" == "None" ]]; then
        echo "ERROR: AMI does not exist in ${SOURCE_REGION}: ${AMI_NAME}"
        exit 1
    fi

    VALIDATED=$(spel_image_tag "$SOURCE_REGION" "$AMI_NAME" "$SPEL_TAG_VALIDATED")
    PUBLIC=$(spel_describe_image "$SOURCE_REGION" "$AMI_NAME" "Public")
    if [[ "$VALIDATED" != "true" && "$PUBLIC" != "True" ]]; then
        echo "ERROR: AMI has not passed validation, refusing to publish: ${AMI_NAME}:${SOURCE_AMI}"
        exit 1
    fi

    DESCRIPTION=$(spel_describe_image "$SOURCE_REGION" "$AMI_NAME" "Description")
    DEPRECATE_AT=$(spel_describe_image "$SOURCE_REGION" "$AMI_NAME" "DeprecationTime")

    REGIONS=("$SOURCE_REGION")
    AMI_IDS=("$SOURCE_AMI")
    for REGION in "${TARGET_REGIONS[@]}"; do
        COPY_ID=$(copy_image "$REGION")
        REGIONS+=("$REGION")
        AMI_IDS+=("$COPY_ID")
    done

    for i in "${!REGIONS[@]}"; do
        wait_image "${REGIONS[$i]}" "${AMI_IDS[$i]}"
    done

    # Copies do not reliably carry the deprecation time, so set it explicitly
    if [[ "$DEPRECATE_AT" != "None" ]]; then
        for i in "${!REGIONS[@]}"; do
            [[ "${REGIONS[$i]}" == "$SOURCE_REGION" ]] && continue
            echo "Setting deprecation time ${DEPRECATE_AT} on ${AMI_NAME}:${AMI_IDS[$i]} in ${REGIONS[$i]}"
            aws ec2 enable-image-deprecation \
                --region "${REGIONS[$i]}" \
                --image-id "${AMI_IDS[$i]}" \
                --deprecate-at "$DEPRECATE_AT" \
                > /dev/null
        done
    fi

    if [[ "$(jq '.Add | length' <<< "$LAUNCH_PERMISSION")" -gt 0 ]]; then
        for i in "${!REGIONS[@]}"; do
            echo "Granting launch permissions ${LAUNCH_PERMISSION} on ${AMI_NAME}:${AMI_IDS[$i]} in ${REGIONS[$i]}"
            aws ec2 modify-image-attribute \
                --region "${REGIONS[$i]}" \
                --image-id "${AMI_IDS[$i]}" \
                --launch-permission "$LAUNCH_PERMISSION"
        done
    fi

    for i in "${!REGIONS[@]}"; do
        IMAGES+=("$(jq -cn \
            --arg name "$AMI_NAME" \
            --arg id "${AMI_IDS[$i]}" \
            --arg region "${REGIONS[$i]}" \
            '{Name: $name, ImageId: $id, Region: $region}')")
    done
done

printf '%s\n' "${IMAGES[@]}" | jq -s '.' | tee "$IMAGES_FILE"
