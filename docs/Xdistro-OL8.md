To support Oracle Linux 8, it will be necessary to install the `oracle-linux-release` and `oracle-linux-release-el8` RPMs. As of the writing of this document, these RPMs may be found at [`https://yum.oracle.com/oracle-linux-8.html`](https://yum.oracle.com/oracle-linux-8.html). The following links are correct as of this document's writing and are suitable for creating an Oracle Linux 8.9 AMI:

- [oracle-linux-release](https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/oraclelinux-release-8.9-1.0.8.el8.x86_64.rpm)
- [oracle-linux-release-el8](https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/oraclelinux-release-el8-1.0-35.el8.x86_64.rpm)

If building an Oracle Linux 8.10 AMI or building in an environment where the public Oracle yum repositories are not available, it will be necessary to locate the correct RPM URLs for your build-needs.

To download/stage these RPMs, execute:

~~~bash
XdistroSetup.sh -d Oracle \
  -k <oraclelinux-release_RPM_URL> \
  -r <oraclelinux-release_RPM_URL>,<oraclelinux-release-el8_RPM_URL> 
~~~

If successful, this should create a `${HOME}/RPM/Oracle` directory with the contents similar to the following:

~~~bash
-rw-r--r-- 1 ec2-user ec2-user 9488772 Nov 17 10:35 oraclelinux-release-8.9-1.0.8.el8.x86_64.rpm
-rw-r--r-- 1 ec2-user ec2-user   21500 Nov 17 14:01 oraclelinux-release-el8-1.0-35.el8.x86_64.rpm
~~~

Once these packages are unpacked, it will be necessary to install the file-contents onto the build-host. The `dnf` utility can be used to install the `oraclelinux-release-el8` RPM. However, because it has a conflict with the Red Hat build-host's own, equivalent package, it will be necessary to use `rpm2cpio` to unpack the `oraclelinux-release` contents and then manually copy key files to the build-host' RPM verification-keys' directory.

Note: if installing into networks with no access to internet-hosted repositoris, it will be necessary to have created private-network RPMS equivalent to the above. It will then be necessary to install both the ones published by CentOS.Org and your organization's equivalent RPMs.

To see an example of the whole sequence for OL8, see the [OL8 text document](buildIt-ol8.txt).

## Install `oraclelinux-release-el8` RPM

Execute a step similar to the following for whichever `oraclelinux-release-el8` version is correct when following this document's guidance.

~~~bash
dnf install ${HOME}/RPM/Oracle/oraclelinux-release-el8-1.0-35.el8.x86_64.rpm
~~~

## Install `oraclelinux-release` RPM

Unpack the `oraclelinux-release` RPM with the `rpm2cpio` utility. This will look something like the following

1. Create an "unpacking" directory (e.g., `mkdir /tmp/unpack`)
2. Navigate into the "unpacking" directory (e.g., `cd /tmp/unpack`)
3. Unpack the RPM (e.g., `rpm2cpio ${HOME}/RPM/Oracle/oraclelinux-release-8.9-1.0.8.el8.x86_64.rpm`)

Once it's unpacked copy the unpacked GPG files (e.g., `/tmp/unpack/etc/pki/rpm-gpg/RPM-GPG-KEY` and `/tmp/unpack/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle`) into the host-system's RPM-keys directory (`/etc/pki/rpm-gpg/`)

