#!/bin/bash
# Do not use `set -e`, as we handle the errexit in the script
set -u -o pipefail

echo "==========STARTING BUILD=========="
echo "Building packer template, spel/minimal-linux.pkr.hcl"

packer build \
  -only "${SPEL_BUILDERS:?}" \
  -var "spel_identifier=${SPEL_IDENTIFIER:?}" \
  -var "spel_version=${SPEL_VERSION:?}" \
  spel/minimal-linux.pkr.hcl

BUILDEXIT=$?

FAILED_BUILDS=()
SUCCESS_BUILDS=()

for BUILDER in ${SPEL_BUILDERS//,/ }; do
  BUILD_NAME="${BUILDER//*./}"
  AMI_NAME="${SPEL_IDENTIFIER}-${BUILD_NAME}-${SPEL_VERSION}.x86_64-gp2"
  BUILDER_ENV="${BUILDER//[.-]/_}"
  BUILDER_AMI=$(aws ec2 describe-images --filters Name=name,Values="$AMI_NAME" --query 'Images[0].ImageId' --out text)
  if [[ "$BUILDER_AMI" == "None" ]]
  then
    FAILED_BUILDS+=("$BUILDER")
  else
    SUCCESS_BUILDS+=("$BUILDER")
    export "$BUILDER_ENV"="$BUILDER_AMI"
  fi
done

if [[ -n "${SUCCESS_BUILDS:-}" ]]
then
  SUCCESS_BUILDERS=$(IFS=, ; echo "${SUCCESS_BUILDS[*]}")
  echo "Successful builds being tested: ${SUCCESS_BUILDERS}"
  packer build \
    -only "$SUCCESS_BUILDERS" \
    -var "spel_identifier=${SPEL_IDENTIFIER:?}" \
    -var "spel_version=${SPEL_VERSION:?}" \
    tests/minimal-linux.pkr.hcl
fi

TESTEXIT=$?

if [[ $BUILDEXIT -ne 0 ]]; then
  FAILED_BUILDERS=$(IFS=, ; echo "${FAILED_BUILDS[*]}")
  echo "ERROR: Failed builds: ${FAILED_BUILDERS}"
  echo "ERROR: Build failed. Scroll up past the test to see the packer error and review the build logs."
  exit $BUILDEXIT
fi

if [[ $TESTEXIT -ne 0 ]]; then
  echo "ERROR: Test failed. Review the test logs for the error."
  exit $TESTEXIT
fi
