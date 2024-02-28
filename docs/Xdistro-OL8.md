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
