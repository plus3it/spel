#!/bin/bash
# Shared helpers for the build, publish, and deregister scripts. Source this file;
# do not execute it.
#
# All lookups are by AMI name and owner "self", so the scripts are idempotent and
# can be re-run safely after a partial failure.

# Used by the scripts that source this file
# shellcheck disable=SC2034
SPEL_TAG_VALIDATED="spel:validated"
# shellcheck disable=SC2034
SPEL_TAG_SOURCE_IMAGE_ID="spel:source-image-id"

# Prints the AMI name for a packer builder, e.g. amazon-ebssurrogate.minimal-rhel-9-hvm
spel_ami_name() {
    local builder="$1"
    echo "${SPEL_IDENTIFIER:?}-${builder//*./}-${SPEL_VERSION:?}.x86_64-gp3"
}

# Prints a field from the AMI with the given name, or "None" if the AMI does not exist.
# Usage: spel_describe_image <region> <ami-name> <jmespath-of-image>
spel_describe_image() {
    local region="$1" name="$2" query="$3"
    aws ec2 describe-images \
        --region "$region" \
        --owners self \
        --filters "Name=name,Values=${name}" \
        --query "Images[0].${query}" \
        --output text
}

# Prints the value of a tag on the AMI with the given name, or "None"
# Usage: spel_image_tag <region> <ami-name> <tag-key>
spel_image_tag() {
    spel_describe_image "$1" "$2" "Tags[?Key=='${3}'].Value | [0]"
}

# Deregisters the AMI with the given name, and deletes its snapshots. Refuses to
# deregister a public AMI unless SPEL_DEREGISTER_PUBLIC=true.
# Usage: spel_deregister_image <region> <ami-name>
spel_deregister_image() {
    local region="$1" name="$2" ami_id public

    ami_id=$(spel_describe_image "$region" "$name" "ImageId") || return 1
    if [[ "$ami_id" == "None" ]]; then
        echo "AMI does not exist, nothing to deregister: ${name} in ${region}"
        return 0
    fi

    public=$(spel_describe_image "$region" "$name" "Public") || return 1
    if [[ "$public" == "True" && "${SPEL_DEREGISTER_PUBLIC:-false}" != "true" ]]; then
        echo "ERROR: Refusing to deregister public AMI ${name}:${ami_id} in ${region}. Set SPEL_DEREGISTER_PUBLIC=true to override."
        return 1
    fi

    echo "Deregistering AMI ${name}:${ami_id} in ${region}"
    aws ec2 deregister-image --region "$region" --image-id "$ami_id" --delete-associated-snapshots
}
