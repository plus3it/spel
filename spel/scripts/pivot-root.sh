#!/bin/bash

##############################################################################
#
# Pivot the root partition to a tmpfs mount point so that the root volume can
# be re-partitioned.
#
##############################################################################

set -x
set -e

# Get fuser
echo "Installing psmisc RPM..."
yum -y install psmisc

# Create tmpfs mount
echo "Creating /tmproot..."
install -Ddm 000755 /tmp/tmproot
echo "Mounting tmpfs to /tmp/tmproot..."
mount none /tmp/tmproot -t tmpfs

# Copy everything to the tmpfs mount
echo "Copying / to /tmp/tmproot..."
cp -ax / /tmp/tmproot

echo "Copying dev-nodes to /tmp/tmproot..."
cp -a /dev /tmp/tmproot

# Switch / to tmpfs
echo "Creating /tmp/tmproot/oldroot..."
mkdir /tmp/tmproot/oldroot

echo "Prepare for pivot_root action..."
mount --make-rprivate /

echo "Execute pivot_root..."
pivot_root /tmp/tmproot /tmp/tmproot/oldroot

echo "Move sub-mounts into /oldroot..."
mount --move /oldroot/dev /dev
mount --move /oldroot/proc /proc
mount --move /oldroot/sys /sys
mount --move /oldroot/run /run
mount --move /oldroot/tmp /tmp || true  # not every ami starts with this

# Unmount everything we can on /oldroot
MOUNTS=$(
    cut -d ' ' -f 2 /proc/mounts | \
    grep '/oldroot/' | \
    sort -ru
)
echo "$MOUNTS" | while IFS= read -r MOUNT
do
    echo "Attempting to dismount ${MOUNT}... "
    umount "$MOUNT" || true
done

# Restart sshd to relink it to /tmp/tmproot
if systemctl is-active --quiet firewalld ; then systemctl stop firewalld ; fi
systemctl restart sshd

# Kill ssh processes, releasing any locks on /oldroot, and forcing packer to reconnect
pkill --signal HUP sshd
