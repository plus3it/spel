## Changelog

### [2025.09.1](https://github.com/plus3it/spel/releases/tag/2025.09.1)

**Released**: 2025.09.23

**Manifests**: <https://github.com/plus3it/spel/blob/2025.09.1/manifests>

**Summary**:
*   First release of SPEL images for Alma Linux 9 and Rocky Linux 9
*   AL2023 images are pinned to `2023.8.20250818`, due to discovered incompatibility
    with `2023.8.20250908`

*   "Extra" packages updated in this release:
    - aws-cli/2.30.7
    - amazon-ssm-agent-3.3.3050.0-1

### [2025.08.1](https://github.com/plus3it/spel/releases/tag/2025.08.1)

**Released**: 2025.08.29

**Manifests**: <https://github.com/plus3it/spel/blob/2025.08.1/manifests>

**Summary**:
*   First release of SPEL images for Amazon Linux 2023
*   Removes `amazon-ec2-net-utils` package from SPEL images
*   Removes `epel-release` package and `epel` yum repo definition from SPEL images

*   "Extra" packages updated in this release:
    - aws-cli/2.28.20
    - amazon-ssm-agent-3.3.2746.0-1
    - spel-release-9-6

### [2025.07.1](https://github.com/plus3it/spel/releases/tag/2025.07.1)

**Released**: 2025.07.22

**Manifests**: <https://github.com/plus3it/spel/blob/2025.07.1/manifests>

**Summary**:
*   EL8: Adds automatic reboot to workaround systemd race condition that drops
    system to emergency mode

*   "Extra" packages updated in this release:
    - aws-cli/2.27.56
    - amazon-ssm-agent-3.3.2656.0-1

### [2025.06.1](https://github.com/plus3it/spel/releases/tag/2025.06.1)

**Released**: 2025.06.18

**Manifests**: <https://github.com/plus3it/spel/blob/2025.06.1/manifests>

**Summary**:
*   "Extra" packages updated in this release:
    - aws-cli/2.27.37
    - amazon-ec2-net-utils-2.6.0-1
    - amazon-ssm-agent-3.3.2471.0-1


### [2025.05.1](https://github.com/plus3it/spel/releases/tag/2025.05.1)

**Released**: 2025.05.23

**Manifests**: <https://github.com/plus3it/spel/blob/2025.05.1/manifests>

**Summary**:
*   Oracle Linux Server 9.6
*   Red Hat Enterprise Linux 9.6
*   "Extra" packages updated in this release:
    - aws-cli/2.27.21

### [2025.04.1](https://github.com/plus3it/spel/releases/tag/2025.04.1)

**Released**: 2025.04.22

**Manifests**: <https://github.com/plus3it/spel/blob/2025.04.1/manifests>

**Summary**:
*   "Extra" packages updated in this release:
    - aws-cli/2.26.6
    - amazon-ssm-agent-3.3.2299.0-1

### [2025.03.1](https://github.com/plus3it/spel/releases/tag/2025.03.1)

**Released**: 2025.03.25

**Manifests**: <https://github.com/plus3it/spel/blob/2025.03.1/manifests>

**Summary**:
*   "Extra" packages updated in this release:
    - aws-cli/2.25.3
    - amazon-ec2-net-utils-2.5.4-1
    - amazon-ssm-agent-3.3.1957.0-1

### [2025.02.1](https://github.com/plus3it/spel/releases/tag/2025.02.1)

**Released**: 2025.02.21

**Manifests**: <https://github.com/plus3it/spel/blob/2025.02.1/manifests>

**Summary**:
*   "Extra" packages updated in this release:
    - aws-cli/2.24.7
    - amazon-ec2-net-utils-2.5.2-1
    - amazon-ssm-agent-3.3.1611.0-1

### [2025.01.1](https://github.com/plus3it/spel/releases/tag/2025.01.1)

**Released**: 2025.01.24

**Manifests**: <https://github.com/plus3it/spel/blob/2025.01.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/2.23.5
    - ec2-utils-2.2.0-1.0.2


### [2024.12.1](https://github.com/plus3it/spel/releases/tag/2024.12.1)

**Released**: 2024.12.23

**Manifests**: <https://github.com/plus3it/spel/blob/2024.12.1/manifests>

**Summary**:

*   Oracle Linux Server 9.5
*   Red Hat Enterprise Linux 9.5
*   "Extra" packages updated in this release:
    - aws-cli/2.22.23
    - amazon-ssm-agent-3.3.1345.0-1
    - spel-dod-certs-5.13-1
    - spel-wcf-certs-5.15-1


### [2024.10.1](https://github.com/plus3it/spel/releases/tag/2024.10.1)

**Released**: 2024.10.24

**Manifests**: <https://github.com/plus3it/spel/blob/2024.10.1/manifests>

**Summary**:

*   Restores AMI deprecation attribute, defaulting to 1 year of public visibility
*   Updates EL9 images to eliminate log messages of the form:

        ```
        [  944.388690] systemd-rc-local-generator[43024]: /etc/rc.d/rc.local is not marked executable, skipping.
        ```

*   "Extra" packages updated in this release:
    - aws-cli/2.18.13
    - amazon-ssm-agent-3.3.987.0-1

### [2024.09.1](https://github.com/plus3it/spel/releases/tag/2024.09.1)

**Released**: 2024.09.17

**Manifests**: <https://github.com/plus3it/spel/blob/2024.09.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/2.17.52
    - amazon-ec2-net-utils-2.5.1-1
    - amazon-ssm-agent-3.3.859.0-1

### [2024.08.1](https://github.com/plus3it/spel/releases/tag/2024.08.1)

**Released**: 2024.08.20

**Manifests**: <https://github.com/plus3it/spel/blob/2024.08.1/manifests>

**Summary**:

*   Updates EL9 images to process grub2 kernel options properly. This resolves
    an issue with network interface device names, as well as console output displaying
    in AWS. See: https://github.com/plus3it/amigen9/issues/26
*   Removed manifests of EL7 images
*   Removed `insights-client` from Red Hat 9 images, due to dependency leakage
    to CentOS Stream and unavailability of the package

*   "Extra" packages updated in this release:
    - aws-cli/2.17.33

### [2024.07.1](https://github.com/plus3it/spel/releases/tag/2024.07.1)

**Released**: 2024.07.23

**Manifests**: <https://github.com/plus3it/spel/blob/2024.07.1/manifests>

**Summary**:

*   Final release of EL7 images

*   "Extra" packages updated in this release:
    - aws-cli/2.17.15
    - amazon-ssm-agent-3.3.551.0-1

### [2024.06.1](https://github.com/plus3it/spel/releases/tag/2024.06.1)

**Released**: 2024.06.20

**Manifests**: <https://github.com/plus3it/spel/blob/2024.06.1/manifests>

**Summary**:

*   Adds links for EL9 builds to README
*   Removes centos-8stream due to end-of-life deprecations

*   "Extra" packages updated in this release:
    - aws-cli/2.16.12
    - amazon-ssm-agent-3.3.484.0-1

### [2024.05.1](https://github.com/plus3it/spel/releases/tag/2024.05.1)

**Released**: 2024.05.21

**Manifests**: <https://github.com/plus3it/spel/blob/2024.05.1/manifests>

**Summary**:

*   Minor release update to RedHat 9.4 and Oracle Linux 9.4
*   Documents process to build EFI-enabled bootstrap AMIs and provides additional
    guidance on creating cross-distro AMIs.

*   "Extra" packages updated in this release:
    - aws-cli/2.15.54
    - amazon-ssm-agent-3.3.418.0-1

### [2024.04.1](https://github.com/plus3it/spel/releases/tag/2024.04.1)

**Released**: 2024.04.23

**Manifests**: <https://github.com/plus3it/spel/blob/2024.04.1/manifests>

**Summary**:

*   EL9 images released for first time, including RHEL9, Centos Stream 9, and Oracle
    Linux 9.
*   Updated amazon builders to use new ebssurrogate feature that will build to
    a secondary volume and then swap the root volume for the secondary volume.
    This eliminates the need to pivot-root to inherit options associated to the
    source image, such as the Red Hat license (for the RHEL images). It also significantly
    reduces transient errors and race conditions in the build process.
*   Uses the new amazon packages from the spel repo, rebased on Amazon Linux 2023.
    This also adds several new amazon packages to EL7/EL8/EL9 images, if they are
    installed by default in AL2023.

*   "Extra" packages updated in this release:
    - aws-cli/2.15.40
    - amazon-ec2-net-utils-2.4.1-1
    - amazon-ssm-agent-3.3.337.0-1
    - (EL7/EL8) ec2-instance-connect-1.1-19
    - (EL7/EL8) ec2-instance-connect-selinux-1.1-19
    - (EL8/EL9) ec2-utils-2.2.0-1

### [2024.03.2](https://github.com/plus3it/spel/releases/tag/2024.03.2)

**Released**: 2024.04.11

**Manifests**: <https://github.com/plus3it/spel/blob/2024.03.2/manifests>

**Summary**:

*   EL8-only release. Increases /boot partition size so there is enough space to
    update kernel packages without error.

*   "Extra" packages updated in this release:
    - aws-cli/2.15.37

### [2024.03.1](https://github.com/plus3it/spel/releases/tag/2024.03.1)

**Released**: 2024.03.21

**Manifests**: <https://github.com/plus3it/spel/blob/2024.03.1/manifests>

**Summary**:

*   Amazon packages rebuilt for the `spel-packages` repo are now based on Amazon
    Linux 2023, instead of Amazon Linux 2. Please see the repo listing for the
    packages available for each platform, <https://spel-packages.cloudarmor.io/list.html>.

*   "Extra" packages updated in this release:
    - aws-cli/2.15.31
    - amazon-ssm-agent-3.3.131.0-1
    - ec2-hibinit-agent-1.0.8-0

### [2024.02.1](https://github.com/plus3it/spel/releases/tag/2024.02.1)

**Released**: 2024.02.21

**Manifests**: <https://github.com/plus3it/spel/blob/2024.02.1/manifests>

**Summary**:

*   Begins adding builders in support of future EL9 releases
*   Supports building EL8 images that work with both EFI and BIOS boot modes. If
    both the builder instance boots in EFI mode, and the source image is marked
    `uefi-preferred`, then the resulting image will inherit `uefi-preferred` and
    will support both EFI and BIOS boot modes. As of this release, only RHEL8 SPEL
    images are marked as `uefi-preferred`. Further work is in-progress for other
    EL8 flavors to build `uefi-preferred` images.

*   "Extra" packages updated in this release:
    - aws-cli/2.15.21
    - amazon-ssm-agent-3.2.2222.0-1

### [2024.01.1](https://github.com/plus3it/spel/releases/tag/2024.01.1)

**Released**: 2024.01.25

**Manifests**: <https://github.com/plus3it/spel/blob/2024.01.1/manifests>

**Summary**:

*   Documents the decommission of the AWS account previously hosting spel images.
    The account is now closed, and the images are no longer accessible.

*   "Extra" packages updated in this release:
    - aws-cli/2.15.14
    - amazon-ssm-agent-3.2.2086.0-1

### [2023.12.1](https://github.com/plus3it/spel/releases/tag/2023.12.1)

**Released**: 2023.12.20

**Manifests**: <https://github.com/plus3it/spel/blob/2023.12.1/manifests>

**Summary**:

*   Updates AMIs to use EBS GP3 volumes

*   "Extra" packages updated in this release:
    - aws-cli/2.15.2
    - amazon-ssm-agent-3.2.2016.0-1

### [2023.11.1](https://github.com/plus3it/spel/releases/tag/2023.11.1)

**Released**: 2023.11.21

**Manifests**: <https://github.com/plus3it/spel/blob/2023.11.1/manifests>

**Summary**:

*   Minor release update to RedHat 8.9 and Oracle Linux 8.9

*   "Extra" packages updated in this release:
    - aws-cli/2.13.37
    - amazon-ssm-agent-3.2.1798.0-1
    - ec2-hibinit-agent-1.0.2-7
    - spel-release-8-4

### [2023.10.1](https://github.com/plus3it/spel/releases/tag/2023.10.1)

**Released**: 2023.10.24

**Manifests**: <https://github.com/plus3it/spel/blob/2023.10.1/manifests>

**Summary**:

*   Updates README to indicate EL8 distros are explicitly supported

*   Documents compatitbility requirements between EL8, OpenSSH, and FIPS

*   "Extra" packages updated in this release:
    - aws-cli/2.13.28
    - amazon-ssm-agent-3.2.1705.0-1
    - ec2-hibinit-agent-1.0.2-5

### [2023.09.1](https://github.com/plus3it/spel/releases/tag/2023.09.1)

**Released**: 2023.09.25

**Manifests**: <https://github.com/plus3it/spel/blob/2023.09.1/manifests>

**Summary**:

*   Ensure AMIGENPKGGRP gets propagated to build-script

*   Adds option to specify a deprecation lifetime for builders that support it

*   Deprecation lifetime for "official" images set to 1 year

*   "Extra" packages updated in this release:
    - aws-cli/2.13.20
    - amazon-ssm-agent-3.2.1542.0-1

### [2023.08.1](https://github.com/plus3it/spel/releases/tag/2023.08.1)

**Released**: 2023.08.24

**Manifests**: <https://github.com/plus3it/spel/blob/2023.08.1/manifests>

**Summary**:

*   Updates overlay to add an additional 1G to root volume

*   "Extra" packages updated in this release:
    - aws-cli/2.13.12
    - amazon-ssm-agent-3.2.1377.0-1
    - spel-dod-certs-5.12-1

### [2023.07.1](https://github.com/plus3it/spel/releases/tag/2023.07.1)

**Released**: 2023.07.19

**Manifests**: <https://github.com/plus3it/spel/blob/2023.07.1/manifests>

**Summary**:

*   Installs packages `spel-dod-certs` and `spel-wcf-certs` by default

*   "Extra" packages updated in this release:
    - aws-cli/2.13.1
    - amazon-ssm-agent-3.2.1297.0-1
    - spel-dod-certs-5.11-1
    - spel-wcf-certs-5.14-1

### [2023.06.1](https://github.com/plus3it/spel/releases/tag/2023.06.1)

**Released**: 2023.06.20

**Manifests**: <https://github.com/plus3it/spel/blob/2023.06.1/manifests>

**Summary**:

*   Exports HTTP_PROXY to EL8 Azure utils script

*   "Extra" packages updated in this release:
    - aws-cli/2.12.1
    - amazon-ssm-agent-3.2.1041.0-1

### [2023.05.2](https://github.com/plus3it/spel/releases/tag/2023.05.2)

**Released**: 2023.05.23

**Manifests**: <https://github.com/plus3it/spel/blob/2023.05.2/manifests>

**Summary**:

*   Minor release update to RedHat 8.8 and Oracle Linux 8.8
*   Adds builder for Azure RHEL8 images
*   Updates test config to support images where default-user has a SELinux role

*   "Extra" packages updated in this release:
    - aws-cli/2.11.21

### [2023.05.1](https://github.com/plus3it/spel/releases/tag/2023.05.1)

**Released**: 2023.05.11

**Manifests**: <https://github.com/plus3it/spel/blob/2023.05.1/manifests>

**Summary**:

*   This was an early release for May 2023 to ncrease the size of the `/` LVM volume
    from 4GB to 5GB for EL7 images in order to reduce issues with yum installs
    when installing security services to bring systems into compliance with enterprise
    requirements. Another release will be made towards the end of the month to
    better capture patches released in May.

*   "Extra" packages updated in this release:
    - aws-cli/2.11.19
    - amazon-ssm-agent-3.2.923.0-1

### [2023.04.1](https://github.com/plus3it/spel/releases/tag/2023.04.1)

**Released**: 2023.04.19

**Manifests**: <https://github.com/plus3it/spel/blob/2023.04.1/manifests>

**Summary**:

*   Removes old json templates, in favor of hcl
*   Updates Microsoft certs for Azure EL7 builds before doing anything else

*   "Extra" packages updated in this release:
    - aws-cli/2.11.13
    - amazon-ssm-agent-3.2.815.0-1


### [2023.03.2](https://github.com/plus3it/spel/releases/tag/2023.03.2)

**Released**: 2023.03.28

**Manifests**: <https://github.com/plus3it/spel/blob/2023.03.2/manifests>

**Summary**:

*   This is an EL8-only release.
*   Increased the size of the `/` LVM volume from 4GB to 5GB for EL8 images

*   "Extra" packages updated in this release:
    - aws-cli/2.11.6

### [2023.03.1](https://github.com/plus3it/spel/releases/tag/2023.03.1)

**Released**: 2023.03.21

**Manifests**: <https://github.com/plus3it/spel/blob/2023.03.1/manifests>

**Summary**:

*   The repos for Oracle Linux 8 appear to have addressed their issues with weak
    dependency resolution. The prior warning published in SPEL 2023.01.1 about
    likely discrepancies between OL8 images and other EL8 images no longer applies.

*   "Extra" packages updated in this release:
    - aws-cli/2.11.4
    - ec2-hibinit-agent-1.0.2-4


### [2023.02.1](https://github.com/plus3it/spel/releases/tag/2023.02.1)

**Released**: 2023.02.21

**Manifests**: <https://github.com/plus3it/spel/blob/2023.02.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/2.10.1
    - amazon-ssm-agent-3.2.582.0-1

### 2023.01.1

**Released**: 2023.01.24

**Commit Delta**: [Change from 2022.12.1 release](https://github.com/plus3it/spel/compare/2022.12.1...2023.01.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2023.01.1/manifests>

**Summary**:

*   Installs `python39` to EL8 images. Previously, `python36` was installed to EL8.
    Now, `python36` is installed only to EL7, and `python39` is installed to EL8.
*   Restores builds for Oracle Linux 8. As part of the investigation, it was realized
    that at some point, probably the 8.7 release, Oracle Linux became unable to
    resolve weak dependencies (those marked in an rpm spec file as "Recommends").
    This is a problem because RHEL8 and all other EL8 derivatives do install weak
    dependencies by default. To fix the OL8 builds, dependencies used expliclity
    by the build process were added as "extra" packages. It is probably good overall
    to explicitly list such dependencies, anyways. **However**, this also means
    it is _likely_ that the OL8 images vary significantly from RHEL8 and other
    EL8 derivatives. Be aware of this delta, and **use caution** if your expectation
    is that the OL8 images are package-equivalent to the RHEL8 images!
*   Separates EL7 and EL8 input arguments for amigen extra packages. This allowed
    installing different versions of python3 to EL7 vs EL8, as well as restoring
    builds for OL8.

*   "Extra" packages updated in this release:
    - aws-cli/2.9.17
    - amazon-ssm-agent-3.2.419.0-1

### 2022.12.1

**Released**: 2022.12.20

**Commit Delta**: [Change from 2022.11.1 release](https://github.com/plus3it/spel/compare/2022.11.1...2022.12.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.12.1/manifests>

**Summary**:

*   Oracle Linux 8 was skipped for this release, as their updated cloud-init package was badly broken.
    Waiting on a response to determine whether they are going to fix it, or if we need to handle the
    brokenness. See also [amigen8/pull/69](https://github.com/plus3it/amigen8/pull/69).

*   "Extra" packages updated in this release:
    - aws-cli/2.9.8
    - amazon-ssm-agent-3.2.286.0-1
    - ec2-net-utils-1.7.3-1

### 2022.11.1

**Released**: 2022.11.23

**Commit Delta**: [Change from 2022.10.1 release](https://github.com/plus3it/spel/compare/2022.10.1...2022.11.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.11.1/manifests>

**Summary**:

*   Red Hat Enterprise Linux release 8.7 (Ootpa)
*   Oracle Linux 8 was skipped for this release, as their updated cloud-init package was badly broken.
    Waiting on a response to determine whether they are going to fix it, or if we need to handle the
    brokenness. See also [amigen8/pull/69](https://github.com/plus3it/amigen8/pull/69).

*   "Extra" packages updated in this release:
    - aws-cli/2.9.0
    - ec2-net-utils-1.7.2-1

### 2022.10.1

**Released**: 2022.10.21

**Commit Delta**: [Change from 2022.09.1 release](https://github.com/plus3it/spel/compare/2022.09.1...2022.10.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.10.1/manifests>

**Summary**:

*   Removed `ec2-instance-connect` as a default-installed package due to incompatibilities with RHEL8 and Oracle Linux 8

*   "Extra" packages updated in this release:
    - aws-cli/2.8.4
    - amazon-ssm-agent-3.1.1927.0-1
    - ec2-net-utils-1.7.1-1

### 2022.09.1

**Released**: 2022.09.20

**Commit Delta**: [Change from 2022.08.1 release](https://github.com/plus3it/spel/compare/2022.08.1...2022.09.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.09.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/2.7.33
    - amazon-ssm-agent-3.1.1767.0-1

### 2022.08.1

**Released**: 2022.08.23

**Commit Delta**: [Change from 2022.07.1 release](https://github.com/plus3it/spel/compare/2022.07.1...2022.08.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.08.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/2.7.25
    - amazon-ssm-agent-3.1.1732.0-1

### 2022.07.1

**Released**: 2022.07.19

**Commit Delta**: [Change from 2022.06.1 release](https://github.com/plus3it/spel/compare/2022.06.1...2022.07.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.07.1/manifests>

**Summary**:

*   Publishes AMIs for Oracle Linux 8
*   "Extra" packages updated in this release:
    - aws-cli/2.7.16
    - amazon-ssm-agent-3.1.1575.0-1

### 2022.06.1

**Released**: 2022.06.21

**Commit Delta**: [Change from 2022.05.1 release](https://github.com/plus3it/spel/compare/2022.05.1...2022.06.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.06.1/manifests>

**Summary**:

*   Removes aws-cli v1 since it no longer supports Python 3.6
*   "Extra" packages updated in this release:
    - aws-cli/2.7.9
    - amazon-ssm-agent-3.1.1511.0-1

### 2022.05.1

**Released**: 2022.05.24

**Commit Delta**: [Change from 2022.04.1 release](https://github.com/plus3it/spel/compare/2022.04.1...2022.05.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.05.1/manifests>

**Summary**:

*   Red Hat Enterprise Linux release 8.6 (Ootpa)
*   "Extra" packages updated in this release:
    - aws-cli/1.24.6
    - aws-cli/2.7.2
    - amazon-ssm-agent-3.1.1374.0-1

### 2022.04.1

**Released**: 2022.04.19

**Commit Delta**: [Change from 2022.03.1 release](https://github.com/plus3it/spel/compare/2022.03.1...2022.04.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.04.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - aws-cli/1.22.98
    - aws-cli/2.5.6
    - amazon-ssm-agent-3.1.1208.0-1
    - ec2-net-utils-1.6.1-2

### 2022.03.1

**Released**: 2022.03.22

**Commit Delta**: [Change from 2022.02.1 release](https://github.com/plus3it/spel/compare/2022.02.1...2022.03.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.03.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - amazon-ssm-agent-3.1.1080.0-1
    - aws-cli/1.22.78
    - aws-cli/2.4.27
    - ec2-net-utils-1.6-1

### 2022.02.1

**Released**: 2022.02.16

**Commit Delta**: [Change from 2022.01.1 release](https://github.com/plus3it/spel/compare/2022.01.1...2022.02.1)

**Manifests**: <https://github.com/plus3it/spel/blob/2022.02.1/manifests>

**Summary**:

*   "Extra" packages updated in this release:
    - amazon-ssm-agent-3.1.941.0-1
    - aws-cli/1.22.55
    - aws-cli/2.4.18

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
