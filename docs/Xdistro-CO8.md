To support CentOS Stream 8, it will be necessary to install the `centos-stream-repos`, `centos-stream-release` and `centos-gpg-keys` RPMs. As of the writing of this document, these RPMs may be found at the CentOS Stream 8 [package-mirror](http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/). The following links are correct as of this document's writing, but can update frequently. Each is suitable for creating a CentOS Stream 8 AMI as of the time of this document's writing:

- [centos-stream-repos](http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-8-6.el8.noarch.rpm)
- [centos-stream-release](http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-release-8.6-1.el8.noarch.rpm)
- [centos-gpg-keys](http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-6.el8.noarch.rpm)


If building in an environment where the public CentOS Stream 8 yum repositories are not available, it will be necessary to locate the correct RPM URLs for your build-needs.

To download/stage these RPMs, execute:

~~~bash
XdistroSetup.sh -d CentOS \
  -k <centos-gpg-keys_RPM_URL> \
  -r <centos-gpg-keys_RPM_URL>,<centos-stream-repos_RPM_URL>,<centos-stream-release_RPM_URL>
~~~

If successful, this should create a `${HOME}/RPM/CentOS` directory with contents similar to the following:

~~~bash
-rw-r--r-- 1 ec2-user ec2-user 14632 Mar 28  2022 centos-gpg-keys-8-6.el8.noarch.rpm
-rw-r--r-- 1 ec2-user ec2-user 22744 Sep 14  2021 centos-stream-release-8.6-1.el8.noarch.rpm
-rw-r--r-- 1 ec2-user ec2-user 20588 Mar 28  2022 centos-stream-repos-8-6.el8.noarch.rpm
~~~

It will then be necessary to install the `centos-gpg-keys` and `centos-stream-repos` to the build-host. Use `dnf` to do so. Once these two RPMs have been installed, it will be necessary to use `yum-config-manager` to disable the repos installed by the `centos-stream-repos` RPM.

Note: if installing into networks with no access to internet-hosted repositoris, it will be necessary to have create private-network RPMS equivalent to the above. It will then be necessary to install both the ones published by CentOS.Org and your organization's equivalent RPMs.

To see an example of the whole sequence for CO8, see the [CO8 text document](buildIt-co8.txt).
