# Using Larger-Than-Default-Root EBS

With the release of the June 2016 AMIs, support for launching instances with larger-than-default root EBSes was added. This added the [dracut-modules-growroot](http://dl.fedoraproject.org/pub/epel/6/x86_64/dracut-modules-growroot-0.20-2.el6.noarch.rpm) EPEL RPM to the "Thin" AMI and extended the RPM's functionality to include support for "`/`" hosted on LVM2 volumes. The patched functionality is implemented via [GrowSetup.sh](https://raw.githubusercontent.com/plus3it/AMIgen6/master/GrowSetup.sh) build-script

> *Note:* a [BugZilla](https://bugzilla.redhat.com/show_bug.cgi?id=1343571) has been opened with the EPEL RPM's maintainer. The patching effected within the build-script will be deprecated if/when the bug is fixed.

To make use of this functionality:

1. Launch an instance from the June 2016 (or newer) "Thin" AMI. On the storage selection screen (if using the Web Console), change the default size value to a more-preferred value.
1. Run the hardening framework (and any other provisioning-time automation) and allow instance to reboot
1. Login to the instance and gain root privileges
1. Run "`pvresize /dev/xvda2`" to ensure that LVM2 "sees" the extra storage in the PV hosting the root volume-group [Note: LVM2 _should_ have properly rescanned the PVs after the reboot. If, however, the "`pvresize`" fails to increase the size of the PV from the default to the expected size, run "`pvscan`" and then re-run the "`pvresize`"]
1. Iteratively use "`lvresize -r VolGroup00/<volName>`" to resize any of the volumes in the root volume-group to their desired size

The final two setps can be placed into an automated-provisionion sequence as a post-reboot task (e.g., place into `/etc/rc.d/rc.local` &mdash; _ensuring to also auto-delete the `rc.local` tasks once executed_)


## Note on Expected Usage

It should be stressed that the above is primarily intended for use by users that have larger-than normal logging need (i.e., use the extra space to increase the size of `logVol` and/or `auditVol`), want a larger swap partition (i.e., use the extra space to grow `swapVol` ...though better performance would be achieved using instance storage for swapping-activities) or need additional home directory space (i.e., use the extra space to grow `homeVol`). Application binaries and data should still be placed onto EBSes (and associated volume-groups) separate from the OS's root volume-group.
