#!/bin/bash
echo "==========STARTING BUILD=========="
echo "Building packer template, spel/minimal-linux.pkr.hcl"

packer build \
  -only "$SPEL_BUILDERS" \
  -var "spel_identifier=$SPEL_IDENTIFIER" \
  -var "spel_version=$SPEL_VERSION" \
  spel/minimal-linux.pkr.hcl

BUILDEXIT=$?

for BUILDER in ${SPEL_BUILDERS//,/ }; do
  BUILD_NAME="${BUILDER//*./}"
  AMI_NAME="${SPEL_IDENTIFIER}-${BUILD_NAME}-${SPEL_VERSION}.x86_64-gp2"
  BUILDER_ENV=$(echo "$BUILDER" | sed -e 's/\./_/g' -e 's/-/_/g')
  BUILDER_AMI=$(aws ec2 describe-images --filters Name=name,Values="$AMI_NAME" --query 'Images[0].ImageId' --out text)
  if [[ "$BUILDER_AMI" != "None" ]]
  then
    export "$BUILDER_ENV"="$BUILDER_AMI"
  fi
done

packer build \
  -only "$SPEL_BUILDERS" \
  -var "spel_identifier=$SPEL_IDENTIFIER" \
  -var "spel_version=$SPEL_VERSION" \
  tests/minimal-linux.pkr.hcl

TESTEXIT=$?

if [[ $BUILDEXIT -ne 0 ]]; then
  echo "Build failed. Scroll up past the test to see the packer error and review the build logs."
  exit $BUILDEXIT
fi

if [[ $TESTEXIT -ne 0 ]]; then
  echo "Test failed. Review the test logs for the error."
  exit $TESTEXIT
fi
