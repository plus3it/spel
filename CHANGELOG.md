## Changelog

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
    -   python34-3.4.8-1.el6
    -   python34-libs-3.4.8-1.el6

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
    -   python34-3.4.8-1.el7
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
