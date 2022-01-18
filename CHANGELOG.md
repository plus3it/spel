## Changelog

### 2022.01.1

**Released**: 2022.01.18

**Commit Delta**: [Change from 2021.12.1 release](https://github.com/plus3it/spel/compare/2021.12.1...2022.01.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.01.1/manifests>

**Summary**:

*   Publishes image for CentOS 8 Stream
*   Deprecates CentOS 8 image -- published `minimal-centos-8-hvm` images will remain available for the time being
*   "Extra" packages updated in this release:
    - amazon-ssm-agent-3.1.804.0-1
    - aws-cli/1.22.37
    - aws-cli/2.4.11
    - aws-cfn-bootstrap (2.0)
    - ec2-hibinit-agent-1.0.2-3
    - ec2-instance-connect-1.1-15
    - ec2-net-utils-1.5-3
*   Yum repo is now being maintained where amazon/aws/ec2 packages are being published
    - A bare minimum of the packages are now pre-installed that align with Amazon Linux 2
    - Other packages are available via the spel repo and can be installed using `yum install ....` 
    - The spel repo itself can be installed using the `spel-release` package
    - The spel repo can be browsed at https://spel-packages.cloudarmor.io

### 2021.12.1

**Released**: 2021.12.21

**Commit Delta**: [Change from 2021.11.1 release](https://github.com/plus3it/spel/compare/2021.11.1...2021.12.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.12.1/manifests>

**Summary**:

*   Publishes images for RHEL 8 and CentOS 8
*   "Extra" packages updated in this release:
    - amazon-ssm-agent-3.1.715.0-1
    - aws-cli/1.22.25
    - aws-cli/2.4.6

### 2021.11.1

**Released**: 2021.11.23

**Commit Delta**: [Change from 2021.10.1 release](https://github.com/plus3it/spel/compare/2021.10.1...2021.11.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.11.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.22.11
    - aws-cli/2.4.0

### 2021.10.1

**Released**: 2021.10.19

**Commit Delta**: [Change from 2021.09.1 release](https://github.com/plus3it/spel/compare/2021.09.1...2021.10.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.10.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.20.64
    - aws-cli/2.2.46

### 2021.09.1

**Released**: 2021.09.23

**Commit Delta**: [Change from 2021.08.1 release](https://github.com/plus3it/spel/compare/2021.08.1...2021.09.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.09.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.20.44
    - aws-cli/2.2.39

### 2021.08.1

**Released**: 2021.08.24

**Commit Delta**: [Change from 2021.07.1 release](https://github.com/plus3it/spel/compare/2021.07.1...2021.08.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.08.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.20.27
    - aws-cli/2.2.31

### 2021.07.1

**Released**: 2021.07.21

**Commit Delta**: [Change from 2021.06.1 release](https://github.com/plus3it/spel/compare/2021.06.1...2021.07.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.07.1/manifests>

**Summary**:

*   aws-cli v1 is now installed using python3
*   "Extra" packages updated in this release:
    - RHEL7: aws-cli/1.20.4
    - CentOS7: aws-cli/1.20.3
    - aws-cli/2.2.21

### 2021.06.1

**Released**: 2021.06.22

**Commit Delta**: [Change from 2021.05.1 release](https://github.com/plus3it/spel/compare/2021.05.1...2021.06.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.06.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.19.98
    - aws-cli/2.2.13

### 2021.05.1

**Released**: 2021.05.19

**Commit Delta**: [Change from 2021.04.1 release](https://github.com/plus3it/spel/compare/2021.04.1...2021.05.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.05.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.19.75
    - aws-cli/2.2.5

### 2021.04.1

**Released**: 2021.04.20

**Commit Delta**: [Change from 2021.03.1 release](https://github.com/plus3it/spel/compare/2021.03.1...2021.04.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.04.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.19.54
    - aws-cli/2.1.38

### 2021.03.1

**Released**: 2021.03.23

**Commit Delta**: [Change from 2021.02.1 release](https://github.com/plus3it/spel/compare/2021.02.1...2021.03.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.03.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.19.34
    - aws-cli/2.1.31
    - rh-amazon-rhui-client-3.0.40

### 2021.02.1

**Released**: 2021.02.23

**Commit Delta**: [Change from 2021.01.1 release](https://github.com/plus3it/spel/compare/2021.01.1...2021.02.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.02.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.19.13
    - aws-cli/2.1.28

### 2021.01.1

**Released**: 2020.01.26

**Commit Delta**: [Change from 2020.12.1 release](https://github.com/plus3it/spel/compare/2020.12.1...2021.01.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2021.01.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.219
    - aws-cli/2.1.21
*   RHEL-only:
    - rh-amazon-rhui-client-3.0.39

### 2020.12.1

**Released**: 2020.12.15

**Commit Delta**: [Change from 2020.10.1 release](https://github.com/plus3it/spel/compare/2020.10.1...2020.12.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.12.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.196
    - aws-cli/2.1.10

*   CentOS-Only:
    - Minor-release update to 7.9 (see [vendor release notes](http://wiki.centos.org/Manuals/ReleaseNotes/CentOS7) for additional details)

### 2020.10.1

**Released**: 2020.10.27

**Commit Delta**: [Change from 2020.09.1 release](http://github.com/plus3it/spel/compare/2020.09.1...2020.10.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.10.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.166
*   RHEL-only:
    - Minor-release update to 7.9 (see [vendor release notes](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/7.9_release_notes/index) for additional details)

### 2020.09.1

**Released**: 2020.09.23

**Commit Delta**: [Change from 2020.08.1 release](http://github.com/plus3it/spel/compare/2020.08.1...2020.09.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.09.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.144

### 2020.08.1

**Released**: 2020.08.25

**Commit Delta**: [Change from 2020.07.1 release](https://github.com/plus3it/spel/compare/2020.07.1...2020.08.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.08.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.125

### 2020.07.1

**Released**: 2020.07.28

**Commit Delta**: [Change from 2020.06.1 release](https://github.com/plus3it/spel/compare/2020.06.1...2020.07.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.07.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.106

### 2020.06.1

**Released**: 2020.06.23

**Commit Delta**: [Change from 2020.05.1 release](https://github.com/plus3it/spel/compare/2020.05.1...2020.06.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.06.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.85
    - amazon-ssm-agent-2.3.1319

### 2020.05.1

**Released**: 2020.05.20

**Commit Delta**: [Change from 2020.04.1 release](https://github.com/plus3it/spel/compare/2020.04.1...2020.05.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.05.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.64

*   CentOS-Only:
    - Minor-release update to 7.8 (see [vendor release notes](http://wiki.centos.org/Manuals/ReleaseNotes/CentOS7) for details of 7.7 to 7.8 changes)

### 2020.04.1

**Released**: 2020.04.21

**Commit Delta**: [Change from 2020.03.1 release](https://github.com/plus3it/spel/compare/2020.03.1...2020.04.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.04.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.42

*   RHEL-only:
    - Minor-release update to 7.8 (see [vendor release notes](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/7.8_release_notes/index) for additional details)
    - rh-amazon-rhui-client-3.0.26

### 2020.03.1

**Released**: 2020.03.26

**Commit Delta**: [Change from 2020.02.1 release](https://github.com/plus3it/spel/compare/2020.02.1...2020.03.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.03.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.18.30

*   Vagrant-only:
    - Manifest file indicates package versions decremented.  Possible build or manifest file upload error. 

### 2020.02.1

**Released**: 2020.02.18

**Commit Delta**: [Change from 2020.01.1 release](https://github.com/plus3it/spel/compare/2020.01.1...2020.02.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.02.1/manifests>

**Summary**:

*   Ensures the cloud-init default user is marked as `uconfined_u` by SELinux
*   "Extra" packages updated in this release:
    - aws-cli/1.18.1

### 2020.01.1

**Released**: 2020.01.21

**Commit Delta**: [Change from 2019.12.1 release](https://github.com/plus3it/spel/compare/2019.12.1...2020.01.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2020.01.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.17.7
    - amazon-ssm-agent-2.3.814.0-1.x86_64

### 2019.12.1

**Released**: 2019.12.17

**Commit Delta**: [Change from 2019.11.1 release](https://github.com/plus3it/spel/compare/2019.11.1...2019.12.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.12.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.16.304

### 2019.11.1

**Released**: 2019.11.19

**Commit Delta**: [Change from 2019.10.1 release](https://github.com/plus3it/spel/compare/2019.10.1...2019.11.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.11.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.16.284
    - amazon-ssm-agent-2.3.760.0-1
    - amazon-linux-extras-1.6.9-2.el7.noarch
    - amazon-linux-extras-yum-plugin-1.6.9-2.el7.noarch
    - ec2-instance-connect-1.1-11.el7.noarch
    - ec2-utils-1.0-2.el7.noarch

### 2019.10.1

**Released**: 2019.10.18

**Commit Delta**: [Change from 2019.09.1 release](https://github.com/plus3it/spel/compare/2019.09.1...2019.10.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.10.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.16.263
    - amazon-ssm-agent-2.3.714.0-1

### 2019.09.1

**Released**: 2019.09.17

**Commit Delta**: [Change from 2019.08.1 release](https://github.com/plus3it/spel/compare/2019.08.1...2019.09.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.09.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.16.239
    - amazon-efs-utils-1.10-1
    - amazon-linux-extras-1.6.9-1
    - amazon-linux-extras-yum-plugin-1.6.9-1
    - amazon-ssm-agent-2.3.707.0-1
    - ec2-instance-connect-1.1-10

*   CentOS-Only:
    - Minor-release update to 7.7 (see [vendor release notes](http://wiki.centos.org/Manuals/ReleaseNotes/CentOS7) for detailing of 7.6 to 7.7 changes)
    - Python 3.6 package from vendor repository (`python3` RPM) obsoletes package from EPEL (`python36` RPM)

### 2019.08.1

**Released**: 2019.08.13

**Commit Delta**: [Change from 2019.07.1 release](https://github.com/plus3it/spel/compare/2019.07.1...2019.08.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.08.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli upgraded to version 1.16.217
    - amazon-ssm-agent RPM upgraded to 2.3.687.0-1.x86_64

*   RHEL-Only:
    - Minor-release update to 7.7 (see [vendor release notes](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7-beta/html/7.7_release_notes/index) for detailing of 7.6 to 7.7 changes)
    - Python 3.6 package from vendor repository (`python3` RPM) obsoletes package from EPEL (`python36` RPM)


### 2019.07.1

**Released**: 2019.07.16

**Commit Delta**: [Change from 2019.06.1 release](https://github.com/plus3it/spel/compare/2019.06.1...2019.07.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.07.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli upgraded to version 1.16.198
    - amazon-ssm-agent RPM upgraded to 2.3.672.0-1
    - ec2-hibinit-agent RPM upgraded to version 1.0.0-4

*   Vendor-packages introduced in this release:
    - acpid RPM

*   "Extra" packages introduced in this release:
    - amazon-ecr-credential-helper (version 0.3.0-1) RPM
    - amazon-ecr-credential-helper-debuginfo (version 0.3.0-1) RPM
    - amazon-efs-utils (version 1.7-1) RPM
    - amazon-linux-extras (version 1.6.8-1) RPM
    - amazon-linux-extras-yum-plugin (version 1.6.8-1) RPM
    - amazonlinux-indexhtml (version 1-1) RPM
    - ec2-instance-connect (version 1.1-9) RPM
    - ec2-net-utils (version 1.1-1.1) RPM
    - ec2sys-autotune (version 1.0.5-1) RPM
    - ec2-utils (version 0.5-1) RPM

*   Newly-activated Services/Agents:
    - [EC2 autotune service](https://github.com/amazonlinux/autotune#description)
    - [Amazon SSM Agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/prereqs-ssm-agent.html)
    - [Amazon Hibernate Agent](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Hibernate.html)
    - [EC2 Instance Connect service](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/)

### 2019.06.1

**Released**: 2019.06.19

**Commit Delta**: [Change from 2019.05.1 release](https://github.com/plus3it/spel/compare/2019.05.1...2019.06.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.06.1/manifests>

**Summary**:

*   Sets `/boot` partition to 512MB for vagrant boxes, see [PR #305](https://github.com/plus3it/spel/pull/305)
*   "Extra" package updates
    - aws-cli/1.16.181
    - amazon-ssm-agent-2.3.662.0-1

### 2019.05.1

**Released**: 2019.05.21

**Commit Delta**: [Change from 2019.04.1 release](https://github.com/plus3it/spel/compare/2019.04.1...2019.05.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.05.1/manifests>

**Summary**:

*   "Extra" package updates
    - aws-cli/1.16.162
    - amazon-ssm-agent-2.3.612
    - python36-3.6.8-1
    - python36-libs-3.6.8-1

### 2019.04.1

**Released**: 2019.04.16

**Commit Delta**: [Change from 2019.03.1 release](https://github.com/plus3it/spel/compare/2019.03.1...2019.04.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.04.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.16.140
    -   amazon-ssm-agent-2.3.539.0-1
    -   python36-3.6.6-5
    -   python36-libs-3.6.6-5

### 2019.03.1

**Released**: 2019.02.19

**Commit Delta**: [Change from 2019.02.1 release](https://github.com/plus3it/spel/compare/2019.02.1...2019.03.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.03.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.16.126
    -   amazon-ssm-agent-2.3.479.0-1
    -   aws-cfn-bootstrap-1.4-31
    -   aws-cli/1.16.126
    -   amazon-ssm-agent-2.3.479.0-1
    -   aws-cfn-bootstrap-1.4-31

### 2019.02.1

**Released**: 2019.02.19

**Commit Delta**: [Change from 2019.01.1 release](https://github.com/plus3it/spel/compare/2019.01.1...2019.02.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.02.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.16.107
    -   amazon-ssm-agent-2.3.444.0-1
    -   python36-libs-3.6.6-2
    -   python36-3.6.6-2

### 2019.01.1

**Released**: 2019.01.16

**Commit Delta**: [Change from 2018.12.1 release](https://github.com/plus3it/spel/compare/2018.12.1...2019.01.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2019.01.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.16.89
    -   amazon-ssm-agent-2.3.372.0-1

### 2018.12.1

**Released**: 2018.12.11

**Commit Delta**: [Change from 2018.11.2 release](https://github.com/plus3it/spel/compare/2018.11.2...2018.12.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.12.1/manifests>

**Summary**:

*   Minor Release
    -   CentOS Linux Release 7.6

*   "Extra" package updates
    -   aws-cli/1.16.72
    -   amazon-ssm-agent-2.3.274

### 2018.11.2

**Released**: 2018.11.14

**Commit Delta**: [Change from 2018.11.1 release](https://github.com/plus3it/spel/compare/2018.11.1...2018.11.2)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.11.2/manifests>

**Summary**:

*   Ensures that the symlink `/usr/bin/python3` exists

*   "Extra" package updates
    -   aws-cli/1.16.54

### 2018.11.1

**Released**: 2018.11.13

**Commit Delta**: [Change from 2018.10.1 release](https://github.com/plus3it/spel/compare/2018.10.1...2018.11.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.11.1/manifests>

**Summary**:

*   Python 3.6 has replaced Python 3.4
*   Builders for EL6 images have been deprecated

*   Minor Release
    -   RedHat 7 Images are now RedHat 7.6

*   "Extra" package updates
    -   aws-cli/1.16.53
    -   amazon-ssm-agent-2.3.235.0-1
    -   python36-3.6.6-1

### 2018.10.1

**Released**: 2018.10.16

**Commit Delta**: [Change from 2018.09.1 release](https://github.com/plus3it/spel/compare/2018.09.1...2018.10.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.10.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.16.34
    -   amazon-ssm-agent-2.3.136.0-1
    -   aws-cfn-bootstrap-1.4-30

### 2018.09.1

**Released**: 2018.09.18

**Commit Delta**: [Change from 2018.08.1 release](https://github.com/plus3it/spel/compare/2018.08.1...2018.09.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.09.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.16.15
    -   amazon-ssm-agent-2.3.68.0-1
    -   (EL7) python34-3.4.9-1

### 2018.08.1

**Released**: 2018.08.16

**Commit Delta**: [Change from 2018.07.1 release](https://github.com/plus3it/spel/compare/2018.07.1...2018.08.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.08.1/manifests>

**Summary**:

*   First publication to VagrantCloud of SPEL Vagrant Box for CentOS7, `plus3it/spel-minimal-centos-7`
*   "Extra" package updates
    -   aws-cli/1.15.77
    -   amazon-ssm-agent-2.2.916.0-1
    -   (RHEL7) python34-3.4.8-2

### 2018.07.1

**Released**: 2018.07.17

**Commit Delta**: [Change from 2018.06.1 release](https://github.com/plus3it/spel/compare/2018.06.1...2018.07.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.07.1/manifests>

**Summary**:

*   "Minor" release updates
    -   RedHat 6 images are now RedHat 6.10
    -   CentOS 6 images are now CentOS 6.10
*   "Extra" package updates
    -   aws-cli/1.15.60
    -   amazon-ssm-agent-2.2.800.0-1

### 2018.06.1

**Released**: 2018.06.18

**Commit Delta**: [Change from 2018.05.1 release](https://github.com/plus3it/spel/compare/2018.05.1...2018.06.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.06.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.15.40
    -   amazon-ssm-agent-2.2.619.0-1
    -   (EL6) python34-3.4.8-1
    -   (EL6) python34-libs-3.4.8-1

### 2018.05.1

**Released**: 2018.05.16

**Commit Delta**: [Change from 2018.04.1 release](https://github.com/plus3it/spel/compare/2018.04.1...2018.05.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.05.1/manifests>

**Summary**:

*   Images have been renamed to remove the "minor" version, e.g.
    `spel-minimal-rhel-7` instead of `spel-minimal-rhel-7.5`; the prior naming
    scheme would become misleading when new minor versions were released
    (but the builder name had not yet been updated to reflect the release);
    this is because spel updates all packages, and a `yum update` will
    automatically update the minor release; the new image names are:
    -   spel-minimal-centos-6
    -   spel-minimal-centos-7
    -   spel-minimal-rhel-6
    -   spel-minimal-rhel-7
*   "Minor" release updates
    -   CentOS 7 images are now CentOS 7.5
*   "Extra" package updates
    -   aws-cli/1.15.20
    -   amazon-ssm-agent-2.2.546.0-1

### 2018.04.1

**Released**: 2018.04.17

**Commit Delta**: [Change from 2018.03.1 release](https://github.com/plus3it/spel/compare/2018.03.1...2018.04.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.04.1/manifests>

**Summary**:

*   "Extra" package updates
    -   aws-cli/1.15.4
    -   amazon-ssm-agent-2.2.392.0-1
    -   (EL7) python34-3.4.8-1
*   spel-minimal-rhel-7.4-hvm
    -   Despite the name, this is a RHEL 7.5 AMI

### 2018.03.1

**Released**: 2018.03.15

**Commit Delta**: [Change from 2018.02.2 release](https://github.com/plus3it/spel/compare/2018.02.2...2018.03.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.03.1/manifests>

**Summary**:

*   Only package updates, see Manifests and the Commit Delta

### 2018.02.2

**Released**: 2018.03.02

**Commit Delta**: [Change from 2018.02.1 release](https://github.com/plus3it/spel/compare/2018.02.1...2018.02.2)

**Manifests**: <https://github.com/plus3it/spel/blob/2018.02.2/manifests>

**Summary**:

*   [[Issue #154][154][PR #155][155] Updates volume group sizes in vagrant
    boxes to match the sizing in the AMIs

[154]: https://github.com/plus3it/spel/issues/154
[155]: https://github.com/plus3it/spel/issues/155
