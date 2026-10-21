#!/bin/bash
set -eu -o pipefail

# shellcheck source=build/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "==========STARTING DEREGISTER=========="

# Deregisters AMIs, and their snapshots, from the build region and every region
# in SPEL_AMI_REGIONS (JSON-encoded list). Public AMIs are skipped, and reported
# as an error, unless SPEL_DEREGISTER_PUBLIC=true.

REGIONS_LIST=$(jq -r --arg source "${AWS_REGION:?}" '[$source] + (. // []) | unique | .[]' <<< "${SPEL_AMI_REGIONS:-[]}")
mapfile -t REGIONS <<< "$REGIONS_LIST"

FAILED=()
for BUILDER in ${SPEL_BUILDERS//,/ }; do
    AMI_NAME=$(spel_ami_name "$BUILDER")
    for REGION in "${REGIONS[@]}"; do
        spel_deregister_image "$REGION" "$AMI_NAME" || FAILED+=("${REGION}:${AMI_NAME}")
    done
done

if [[ ${#FAILED[@]} -ne 0 ]]; then
    echo "ERROR: Failed to deregister: ${FAILED[*]}"
    exit 1
fi
