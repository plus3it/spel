#!/bin/bash
set -eu -o pipefail

echo "==========STARTING PRE_BUILD=========="
echo "Validating packer template, spel/minimal-linux.pkr.hcl"

packer validate \
    -only "${SPEL_BUILDERS:?}" \
    -var "spel_identifier=${SPEL_IDENTIFIER:?}" \
    -var "spel_version=${SPEL_VERSION:?}" \
    spel/minimal-linux.pkr.hcl
