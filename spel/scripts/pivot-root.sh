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

# Get rid of anything that might be in the /boot hierarchy
for BOOT_DIR in /boot{/efi,}
do
  if  [[ -d ${BOOT_DIR} ]] &&
      [[ $( mountpoint "${BOOT_DIR}" ) == "${BOOT_DIR} is a mountpoint" ]]
  then
    fuser -vmk "${BOOT_DIR}" || true
    umount "${BOOT_DIR}"
  fi
done


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
if [[ $( mountpoint /oldroot/tmp ) =~ "is a mountpoint" ]]
then
  mount --move /oldroot/tmp /tmp
fi

# Unmount everything we can on /oldroot
MOUNTS=$(
    cut -d ' ' -f 2 /proc/mounts | \
    grep '/oldroot/' | \
    sort -ru
)
if [[ ${#MOUNTS} -ne 0 ]]
then
  echo "Attempting to clear stragglers found in /proc/mounts"

  echo "$MOUNTS" | while IFS= read -r MOUNT
  do
    echo "Attempting to dismount ${MOUNT}... "
    umount "$MOUNT" || true
  done
else
  echo "Found no stragglers in /proc/mounts"
fi

# Restart sshd to relink it to /tmp/tmproot
if systemctl is-active --quiet firewalld ; then systemctl stop firewalld ; fi
systemctl restart sshd

# Kill ssh processes, releasing any locks on /oldroot, and forcing packer to reconnect
pkill --signal HUP sshd
