## Changelog

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
