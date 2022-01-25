#!/bin/bash
set -eu -o pipefail

echo "==========STARTING INSTALL========="
echo "Installing unzip............"
hash unzip 2> /dev/null || apt -y install unzip
echo "Installing packer..."
echo "$PWD"
if ! hash packer 2> /dev/null
then
  curl -L "$PACKER_ZIP" -o packer.zip
  unzip packer.zip
  mkdir -p "${HOME}/.local/bin"
  mv packer "${HOME}/.local/bin"
fi
packer version

# Check if $SPEL_SSM_ACCESS_KEY is not empty
if [[ -n "${SPEL_SSM_ACCESS_KEY:-}" ]]; then
  SSM_ACCESS_KEY=$(aws ssm get-parameters --name "$SPEL_SSM_ACCESS_KEY" --with-decryption --query 'Parameters[0].Value' --out text)
  if [[ "$SSM_ACCESS_KEY" == "None" ]]; then
    echo "SSM_ACCESS_KEY is undefined"; exit 1
  else
    aws configure set aws_access_key_id "$SSM_ACCESS_KEY" --profile "$SPEL_IDENTIFIER"
  fi

  SSM_SECRET_KEY=$(aws ssm get-parameters --name "$SPEL_SSM_SECRET_KEY" --with-decryption --query 'Parameters[0].Value' --out text)
  if [[ "$SSM_SECRET_KEY" == "None" ]]; then
    echo "SSM_SECRET_KEY is undefined"; exit 1
  else
    aws configure set aws_secret_access_key "$SSM_SECRET_KEY" --profile "$SPEL_IDENTIFIER"
  fi
elif [[ -n "${AWS_ACCESS_KEY_ID:-}" ]]; then
  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$SPEL_IDENTIFIER"
  aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$SPEL_IDENTIFIER"
fi

# Setup the profile region
aws configure set region "${PKR_VAR_aws_region:?}" --profile "$SPEL_IDENTIFIER"
