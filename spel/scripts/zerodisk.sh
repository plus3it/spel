#!/bin/bash

# Zero out the free space to save space in the final image:
echo "zeroing out free space"
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

# Sync to ensure that the delete completes before this moves on.
sync
sync
sync
