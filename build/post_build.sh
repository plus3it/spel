#!/bin/bash
set -eu -o pipefail

# shellcheck source=build/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

echo "==========STARTING POST_BUILD=========="

if [[ "${SPEL_CI:?}" = "true" ]]; then
    for BUILDER in ${SPEL_BUILDERS//,/ }; do
        spel_deregister_image "${AWS_REGION:?}" "$(spel_ami_name "$BUILDER")"
    done
fi

echo "Packer build completed on $(date)"
