#!/bin/bash
echo "==========STARTING INSTALL========="
echo "Installing unzip............"
apt -y install unzip
echo "Installing packer..."
echo "$PWD"
curl -L "$PACKER_ZIP" -o packer.zip && unzip packer.zip

# Check if $SPEL_ACCESS_KEY is not empty
if [ -n "$SPEL_ACCESS_KEY" ]; then
    export AWS_ACCESS_KEY_ID=$SPEL_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=$SPEL_SECRET_KEY
fi

# Check if $SPEL_SSM_ACCESS_KEY is not empty
if [ -n "$SPEL_SSM_ACCESS_KEY" ]; then
  SSM_ACCESS_KEY=$(aws ssm get-parameters --name "$SPEL_SSM_ACCESS_KEY" --with-decryption --query 'Parameters[0].Value' --out text)
  if [ "$SSM_ACCESS_KEY" == "None" ]; then
    echo "SSM_ACCESS_KEY is undefined"; exit 1
  else
    aws configure set aws_access_key_id "$SSM_ACCESS_KEY" --profile "$SPEL_IDENTIFIER"
  fi

  SSM_SECRET_KEY=$(aws ssm get-parameters --name "$SPEL_SSM_SECRET_KEY" --with-decryption --query 'Parameters[0].Value' --out text)
  if [ "$SSM_SECRET_KEY" == "None" ]; then
    echo "SSM_SECRET_KEY is undefined"; exit 1
  else
    aws configure set aws_secret_access_key "$SSM_SECRET_KEY" --profile "$SPEL_IDENTIFIER"
  fi
elif [ -n "$AWS_ACCESS_KEY_ID" ]; then
  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$SPEL_IDENTIFIER"
  aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$SPEL_IDENTIFIER"
fi

# Setup the profile region
aws configure set region "$AWS_REGION" --profile "$SPEL_IDENTIFIER"
