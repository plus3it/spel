[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)

# spel

STIG-Partitioned Enterprise Linux (_spel_) is a project that helps create and
publish Enterprise Linux images that are partitioned according to the
[DISA STIG][0]. The resulting images also use LVM to simplify volume management.
The images are configured with help from the scripts and packages in the
[`AMIgen7`][31], [`AMIgen8`][40], and  [`AMIgen9`][47] projects[^1].

Notes on Lifecycle:

1.  Images are released on a monthly cadence. This cadence ensures that, if a
    user launches a brand new instance from the most-recently published AMI,
    that there will be less than a month's worth of system-patches to apply as
    part of the system-owner's system-provisioning processes.
1.  "Free" Enterprise Linux distributions are configured to use the public
    repositories offered by the distribution-owner. If running EC2s inside of a
    VPC with no access to the internet at large, it will not be possible to
    install additional RPMs or patch systems without the use of either a proxy
    or standing up a private yum mirror
1.  Red Hat images are configured to use a given cloud service provider's (CSP) 
    [Red Hat Update Infrastructure](https://access.redhat.com/products/red-hat-update-infrastructure)
    (a.k.a., "RHUI") repositories. These repositories are managed by Red 
    Hat engineers and provide local RPM update-service within each 
    CSP-partner's networks. Unlike RPM-access via RHN or Satellite, RHUI access 
    is tied to and paid for via your CSP's billing-mechanisms. RHUI access also 
    entitles cloud-VMs' owners to limited operating system support through the 
    respective CSP's support channels.
1.  AWS Specific notes:
    * Access to the RHUI repositories is gated, in part, by an attribute
      attached to EC2s. This attribute is inherited from their corresponding
      AMIs. To view this attribute external to the EC2, execute:

        ~~~
        aws ec2 describe-instances --query 'Reservations[].Instances[].UsageOperation' --instance-ids
        ~~~

      This _should_ return a value of `RunInstances:0010`. If the value is just
      `RunInstances` the necessary attribute is missing from the EC2.

      The attribute may also be viewed internal to the EC2 by executing:

        ~~~
        curl http://169.254.169.254/latest/dynamic/instance-identity/document | \
        grep "billingProducts"
        ~~~

      This _should_ return a value of `"billingProducts" : [ "bp-6fa54006" ]`.
      If not, the necessary attribute is missing from the EC2.

      In either case, lack of the requisite attribute will mean that attempts to
      install or update RPMs from RHUI will fail.
    * If patch-updates should come from RHN, Satellite or other private
      repository, do not use the AMIs published by the maintainers of this
      project. Because the previously-mentioned EC2-attribute is attached to
      such AMIs, you will be billed for the RHUI access even if you never use
      it. Feel free to use this project's code to generate your own,
      unencumbered AMIs.
    * Further information about AWS polices for Red Hat EC2s may be found in
      AWS's [RHEL FAQ](https://aws.amazon.com/partners/redhat/faqs/)

## Why spel

VMs' root filesystems are generally not live-repartitionable once launced from
their images. As a result, if a STIG-scan is performed against most of the
community-published images for Red Hat and related distros (CentOS/CentOS
Stream, [Oracle Linux][41], [Rocky][42], [Alma][43] or [Liberty][44]), those
scans will note failures for each of the various "`${DIRECTORY}` is on its own
filesystem" tests. The images produced through this project are designed to
ensure that these particular scan-failures do not occur.

Aside from addressing the previously-noted partitioning findings, spel applies
only those STIG-related hardenings that need to be in place "from birth" (i.e.,
when a system is first created from KickStart, VM-template, Amazon Machine
Image, etc.). This includes things like:

- Activation of SELinux
  - Application of SELinux user-confinement to the default-user[^2]
  - Application of SELinux role-transition rules for the default-user
- Activation of FIPS mode
- Support for BIOS- and/or EFI-boot modes (the latter being a requisite for use
  of [SecureBoot](https://access.redhat.com/articles/5254641))

The spel-produced images are expected to act as a better starting-point in a
larger hardening process.

If your organization does not already have an automated hardening process,
please see our tool, [Watchmaker](https://github.com/plus3it/watchmaker.git).
This tool is meant to help spel-users (and users of other Enterprise Linux
images) by performing launch-time hardening activities.

## We have a FAQ now!

We've added an [FAQ](docs/FAQ.md) to the project. Hopefully, your questions are
answered there. If they aren't, please feel free to submit an issue requesting
an appropriate FAQ entry.

## Current Published Images

SPEL AMIs are published monthly. The AMI table below contains links to the AWS
Console that search by AMI Name and sort the result by creation date. The most
recent AMI of each build will be at the top when viewed in the AWS Console.

RPM Manifests for published images are available in the [manifests](manifests)
directory.

**Please note:** the RPM-manifests published to this directory are generated
for the AWS (CONUS) commercial regions. Due to potential deltas between the
repositories used for the commercial and govcloud regions, there _may_ also
exist deltas between what is found in the manifests in this project and the
version-numbers found in the GovCloud region AMIs.

| AWS Region    | Builder Name / Link                     |
|---------------|-----------------------------------------|
| us-east-1     | [spel-minimal-rhel-8-hvm][1027]         |
|               | [spel-minimal-ol-8-hvm][1045]           |
|               | [spel-minimal-rhel-9-hvm][1051]         |
|               | [spel-minimal-ol-9-hvm][1063]           |
|               | [spel-minimal-centos-9stream-hvm][1069] |
|               | [spel-minimal-amzn-2023-hvm][1057]      |
| us-east-2     | [spel-minimal-rhel-8-hvm][1029]         |
|               | [spel-minimal-ol-8-hvm][1046]           |
|               | [spel-minimal-rhel-9-hvm][1052]         |
|               | [spel-minimal-ol-9-hvm][1064]           |
|               | [spel-minimal-centos-9stream-hvm][1070] |
|               | [spel-minimal-amzn-2023-hvm][1057]      |
| us-west-1     | [spel-minimal-rhel-8-hvm][1031]         |
|               | [spel-minimal-ol-8-hvm][1047]           |
|               | [spel-minimal-rhel-9-hvm][1053]         |
|               | [spel-minimal-ol-9-hvm][1065]           |
|               | [spel-minimal-centos-9stream-hvm][1071] |
|               | [spel-minimal-amzn-2023-hvm][1057]      |
| us-west-2     | [spel-minimal-rhel-8-hvm][1033]         |
|               | [spel-minimal-ol-8-hvm][1048]           |
|               | [spel-minimal-rhel-9-hvm][1054]         |
|               | [spel-minimal-ol-9-hvm][1066]           |
|               | [spel-minimal-centos-9stream-hvm][1072] |
|               | [spel-minimal-amzn-2023-hvm][1057]      |
| us-gov-west-1 | [spel-minimal-rhel-8-hvm][1035]         |
|               | [spel-minimal-ol-8-hvm][1049]           |
|               | [spel-minimal-rhel-9-hvm][1055]         |
|               | [spel-minimal-ol-9-hvm][1067]           |
|               | [spel-minimal-centos-9stream-hvm][1073] |
|               | [spel-minimal-amzn-2023-hvm][1057]      |
| us-gov-east-1 | [spel-minimal-rhel-8-hvm][1037]         |
|               | [spel-minimal-ol-8-hvm][1050]           |
|               | [spel-minimal-rhel-9-hvm][1056]         |
|               | [spel-minimal-ol-9-hvm][1068]           |
|               | [spel-minimal-centos-9stream-hvm][1062] |
|               | [spel-minimal-amzn-2023-hvm][1074]      |

| Vagrant Cloud Name                          | Vagrant Provider |
|---------------------------------------------|------------------|
| [plus3it/spel-minimal-centos-9stream][2002] | virtualbox       |

## Official AWS Owner Account IDs for Images

The following table lists the official owner accounts for the images.

| AWS Partition | Account ID   | Effective Release     |
|---------------|--------------|-----------------------|
| aws           | 174003430611 | 2023.08.1 and later   |
| aws-us-gov    | 216406534498 | 2023.08.1 and later   |

## Deprecated AWS Owner Account IDs

The following table lists AWS account IDs previously used to host SPEL images.
These accounts are now closed, and the associated images are no longer available.

| AWS Partition | Account ID   | Effective Release     |
|---------------|--------------|-----------------------|
| aws           | 701759196663 | 2023.07.1 and earlier |
| aws-us-gov    | 039368651566 | 2023.07.1 and earlier |

## Deprecated Images

Deprecated Images have become end-of-life and no longer have available yum repos.
The images remain public until the image deprecation period expires, typically
1 year after publishing.

| AWS Region    | Builder Name / Link                     |
|---------------|-----------------------------------------|
| us-east-1     | [spel-minimal-rhel-7-hvm][1000]         |
|               | [spel-minimal-centos-7-hvm][1002]       |
|               | [spel-minimal-centos-8stream-hvm][1039] |
| us-east-2     | [spel-minimal-rhel-7-hvm][1005]         |
|               | [spel-minimal-centos-7-hvm][1007]       |
|               | [spel-minimal-centos-8stream-hvm][1040] |
| us-west-1     | [spel-minimal-rhel-7-hvm][1010]         |
|               | [spel-minimal-centos-7-hvm][1012]       |
|               | [spel-minimal-centos-8stream-hvm][1041] |
| us-west-2     | [spel-minimal-rhel-7-hvm][1015]         |
|               | [spel-minimal-centos-7-hvm][1017]       |
|               | [spel-minimal-centos-8stream-hvm][1042] |
| us-gov-west-1 | [spel-minimal-rhel-7-hvm][1020]         |
|               | [spel-minimal-centos-7-hvm][1022]       |
|               | [spel-minimal-centos-8stream-hvm][1043] |
| us-gov-east-1 | [spel-minimal-rhel-7-hvm][1025]         |
|               | [spel-minimal-centos-7-hvm][1026]       |
|               | [spel-minimal-centos-8stream-hvm][1044] |

| Vagrant Cloud Name                    | Vagrant Provider |
|---------------------------------------|------------------|
| [plus3it/spel-minimal-centos-7][2001] | virtualbox       |

[1000]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-7-hvm-2024.07.1;v=3>
[1002]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-7-hvm-2024.07.1;v=3>
[1005]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-7-hvm-2024.07.1;v=3>
[1007]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-7-hvm-2024.07.1;v=3>
[1010]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-7-hvm-2024.07.1;v=3>
[1012]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-7-hvm-2024.07.1;v=3>
[1015]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-7-hvm-2024.07.1;v=3>
[1017]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-7-hvm-2024.07.1;v=3>
[1020]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-rhel-7-hvm-2024.07.1;v=3>
[1022]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-centos-7-hvm-2024.07.1;v=3>
[1025]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-rhel-7-hvm-2024.07.1;v=3>
[1026]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-centos-7-hvm-2024.07.1;v=3>

[1027]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-8-hvm-2025.10.1;v=3>
[1029]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-8-hvm-2025.10.1;v=3>
[1031]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-8-hvm-2025.10.1;v=3>
[1033]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-8-hvm-2025.10.1;v=3>
[1035]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-rhel-8-hvm-2025.10.1;v=3>
[1037]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-rhel-8-hvm-2025.10.1;v=3>

[1039]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-8stream-hvm;v=3>
[1040]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-8stream-hvm;v=3>
[1041]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-8stream-hvm;v=3>
[1042]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-8stream-hvm;v=3>
[1043]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-centos-8stream-hvm;v=3>
[1044]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-centos-8stream-hvm;v=3>

[1045]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-8-hvm-2025.10.1;v=3>
[1046]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-8-hvm-2025.10.1;v=3>
[1047]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-8-hvm-2025.10.1;v=3>
[1048]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-8-hvm-2025.10.1;v=3>
[1049]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-ol-8-hvm-2025.10.1;v=3>
[1050]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-ol-8-hvm-2025.10.1;v=3>

[1051]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-9-hvm-2025.10.1;v=3>
[1052]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-9-hvm-2025.10.1;v=3>
[1053]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-9-hvm-2025.10.1;v=3>
[1054]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-rhel-9-hvm-2025.10.1;v=3>
[1055]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-rhel-9-hvm-2025.10.1;v=3>
[1056]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-rhel-9-hvm-2025.10.1;v=3>

[1057]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-9stream-hvm-2025.10.1;v=3>
[1058]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-9stream-hvm-2025.10.1;v=3>
[1059]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-9stream-hvm-2025.10.1;v=3>
[1060]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-centos-9stream-hvm-2025.10.1;v=3>
[1061]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-centos-9stream-hvm-2025.10.1;v=3>
[1062]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-centos-9stream-hvm-2025.10.1;v=3>

[1063]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-9-hvm-2025.10.1;v=3>
[1064]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-9-hvm-2025.10.1;v=3>
[1065]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-9-hvm-2025.10.1;v=3>
[1066]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-ol-9-hvm-2025.10.1;v=3>
[1067]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-ol-9-hvm-2025.10.1;v=3>
[1068]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-ol-9-hvm-2025.10.1;v=3>

[1069]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-amzn-2023-hvm-2025.10.1;v=3>
[1070]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-amzn-2023-hvm-2025.10.1;v=3>
[1071]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-amzn-2023-hvm-2025.10.1;v=3>
[1072]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;owner=174003430611;imageName=:spel-minimal-amzn-2023-hvm-2025.10.1;v=3>
[1073]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-amzn-2023-hvm-2025.10.1;v=3>
[1074]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;owner=216406534498;imageName=:spel-minimal-amzn-2023-hvm-2025.10.1;v=3>

[2001]: <https://app.vagrantup.com/plus3it/boxes/spel-minimal-centos-7>
[2002]: <https://app.vagrantup.com/plus3it/boxes/spel-minimal-centos-9stream>

## Default Username

The default username for all spel images is `maintuser`.

If you wish to change the default username at launch, you can do so via
`cloud-init` with userdata[^3] something like the following. Change `<USERNAME>` to
your desired value.

```yaml
#cloud-config
system_info:
  default_user:
    name: <USERNAME>
    gecos: spel default user
    lock_passwd: true
```


## Default User Security-Constraints

Due to updates to the STIGs &ndash; currently just for EL7, but it is assumed
that similar changes for EL8 and later distros will be added to future
STIG-releases &ndash; the default-user's account _may_ have additional SELinux
rules applied to it. These rules will typically manifest in processes that
start as the default-user (i.e., processes run as the `root` user _after_
privilege-escalation via the `sudo` subsystem) receiving `permission denied`
errors when attempting to access "sensitive" files.  These "sensitive" files
are any that have the `shadow_t` SELinux context-label applied to them. By
default, these will only include:

- /etc/security/opasswd
- /etc/shadow
- /etc/gshadow

A definitive list may be gathered by executing the command:

```
find / -context "*shadow_t*"`
```

If your workflows absolutely _require_ the ability to access these files after
a role-transition from the default-user account to `root`, it will be necessary
to update the userData payload's `cloud-config` content to include a block
similar to:

```yaml
#cloud-config
system_info:
  default_user:
    name: <USERNAME>
    gecos: spel default user
    lock_passwd: true
    selinux_user: unconfined_u
    sudo: ["ALL=(root) NOPASSWD:ALL"]
```

However, doing so will result in security scan-failures when the scanning-tool
tries to ensure that all locally-managed, interactive users are
properly-constrained users and, where appropriate, have SELinux
privilege-transition rules defined.

## Prerequisites

[`Packer`][2] by [Hashicorp][1] is used to manage the process of building
images.

1.  [Download][3] and extract `packer` for your platform. Add it to your PATH,
    if you like. On Linux, watch out for other `packer` executables with the
    same name (if building from an Enterprise Linux distro, `/sbin/packer` may
    be present due to the `cracklib-dicts` RPM).

2.  If building AMIs for Amazon Web Services, ensure your [AWS credentials are
    configured][4]. You do not really need the `aws` cli utility, but it is a
    convenient way to configure the credential file. You can also export the
    [environment variables][5]. Or, if running `packer` in an EC2 instance, an
    [instance role][6] with the requisite permissions will also work. See the
    [`packer` docs][7] for details on the necessary permissions.

    _NOTE_: No packer templates in this project will contain variables for AWS
    credentials; this is intentional, to avoid mistakes where credentials get
    committed to the repository. Instead, `packer` knows to read the
    credentials from the credential file or from the environment variables, or
    to retrieve them from the instance role. See the [docs][7].

3.  If building VirtualBox image(s), you will need to install [VirtualBox][12]
    and [Vagrant][13].

4.  If building VMware image(s), [depending on your platform][14], you will
    need to install either [VMware Fusion][15], [VMware Workstation Pro][16], or
    [VMware Player][17]. For all platforms, you will also need [Vagrant][13].

5.  The template(s) push the Vagrant boxes for the VirtualBox and VMware images
to [Hashicorp Vagrant Cloud][19], which requires a [Vagrant Cloud account][21].

6.  If building a VHD or Image for Azure, ensure you have [authorized access
    to ARM][23]. The creation of destination objects and a Service Principal
    can either be done [manually][24] or via [script][25]. If not building in
    Public region, use of device login is not possible and a Service Principal
    is required.

## Usage

_NOTE_: In all steps below, the examples use syntax that works on Linux. If you
are running `packer` from a Windows system, simply use the appropriate syntax
for the _relative path_ to the packer template. Most important, for Windows,
use `.\` preceding the path to the template. E.g.
`.\spel\minimal-linux.json`.

1.  Clone the repository:

    ```bash
    git clone https://github.com/plus3it/spel && cd spel
    ```

2.  Validate the template (Optional):

    ```bash
    packer validate spel/minimal-linux.pkr.hcl
    ```

    The project-included Packer HCL files have been pre-validated. If you
    encounter validation-errors with the included HCL files, it means that
    you're using a newer Packer version than the project has been tested
    against. Please open an [issue][46] to report the problem, ensuring to
    include the Packer version you were using when you encountered the problem.

3.  Begin the build. This requires at least two variables,
    `spel_identifier` and `spel_version`. See the section [Packer Variables](#minimal-linux-packer-variables)
    for more details.

    ```bash
    packer build \
        -var 'spel_identifier=unique-project-id' \
        -var 'spel_version=dev001' \
        -var 'virtualbox_vagrantcloud_username=myvagrantclouduser' \
        spel/minimal-linux.pkr.hcl
    ```

    _NOTE_: This will build images for _all_ the [builders defined in the
    template](#minimal-linux-packer-builders). Use `packer build --help` to
    see how to restrict the build to to a subset of the builders using the `-only`
    or `-except` arguments.

    If building the VirtualBox or VMware images for use with Vagrant, the
    template is configured to host the resulting images with
    [Hashicorp Vagrant Cloud][19]. This requires passing the variable
    `virtualbox_vagrantcloud_username` and exporting the environment variable
    [`VAGRANT_CLOUD_TOKEN`][20].

## Minimal Linux Packer Template

The Minimal Linux template builds STIG-partitioned images with a set of
packages that correspond to the "Minimal" install option in Anaconda. Further,
the AWS images include a handful of additional packages that are intended to
increase functionality in EC2 and make the images more comparable with Amazon
Linux. Similarly, the Azure builder will attempt to install the `WALinuxAgent`
RPM into the VM-template to make the template more integratable into
Azure-based deployments.

-   _Template Path_: `spel/minimal-linux.pkr.hcl`

For all inputs to the template, see [spel/README.md](spel/README.md)

### Minimal Linux Packer Builders

The Minimal Linux `packer` template includes the following builders:

| Builder Name                                     | Description                                                      |
|--------------------------------------------------|------------------------------------------------------------------|
| `amazon-ebssurrogate.minimal-centos-9stream-hvm` | amazon-ebs builder for a minimal CentOS Stream 9 HVM AMI         |
| `amazon-ebssurrogate.minimal-ol-9-hvm`           | amazon-ebs builder for a minimal Oracle Linux 9 HVM AMI          |
| `amazon-ebssurrogate.minimal-rhel-9-hvm`         | amazon-ebs builder for a minimal RHEL 9 HVM AMI                  |
| `amazon-ebssurrogate.minimal-ol-8-hvm`           | amazon-ebs builder for a minimal Oracle Linux 8 HVM AMI          |
| `amazon-ebssurrogate.minimal-rhel-8-hvm`         | amazon-ebs builder for a minimal RHEL 8 HVM AMI                  |
| `virtualbox-iso.minimal-centos-9stream-image`    | virtualbox-iso builder for a minimal CentOS Stream 9 Vagrant Box |

### Minimal Linux Packer Post-Provisioners

The Minimal Linux `packer` template includes the following post-provisioners:

-   `vagrant`: The vagrant post-provisioner creates vagrant boxes from on the
    `virtualbox` and `vmware` images.

-   `vagrant-cloud`: The vagrant-cloud post-provisioners upload the vagrant
    boxes to [Hashicorp Vagrant Cloud][19].

## Building for the AWS US GovCloud Region

To build images for the AWS US GovCloud regions, `us-gov-west-1` or `us-gov-east-1`,
it is necessary to pass several variables that are specific to the region. The
AMI filters below have been tested and/or created in `us-gov-west-1` to work with the
_spel_ template(s). Also, the builders should be restricted so as _not_ to build
the Vagrant images.

```bash
packer build \
    -var 'spel_identifier=unique-project-id' \
    -var 'spel_version=dev001' \
    -var 'aws_region=us-gov-west-1' \
    -exclude 'virtualbox-iso.*' \
    spel/minimal-linux.pkr.hcl
```

## Building for Microsoft Azure

A source Marketplace Image Offer or Custom Image Name and Resource Group are required
from which to start the SPEL Azure build.

The resultant SPEL Image will be configured to use the Azure Linux agent, [WALinuxAgent][27]
per recommended [configurations][28]. Currently, the use of cloud-init exclusively
does not enable execution/installation of [Azure VM Extensions][30]. The below
variables also disable FIPS mode in the resultant SPEL VHD or Image. Currently,
the Azure Linux agent [does not support FIPS mode][29] when utilizing Azure VM
Extensions. If no plans exist to utilize Azure VM Extensions on VMs provisioned
from SPEL VHDs or Images, FIPS mode can be enabled, but the `waagent` configuration
must also be modified accordingly.

The variables referenced in the packer builds below should be modified with
appropriate parameters for your environment. Any content between and including
the < and > characters should be replaced.

Login to azure using the az cli. Packer will use the session setup by the az cli.

```bash
packer build \
    -var 'spel_identifier=unique-project-id' \
    -var 'spel_version=0.0.1' \
    -var 'amigen_extra_rpms=["WALinuxAgent"]' \
    -var 'amigen_fips_disable=true' \
    -var 'amigen8_repo_names=["rhui-microsoft-azure-rhel8"]' \
    -var 'azure_image_offer=rhel-raw' \
    -var 'azure_image_publisher=RedHat' \
    -var 'azure_image_sku=8_8' \
    -var 'azure_managed_image_resource_group_name=<resource group short name>' \
    -only 'azure-arm.minimal-rhel-8-image' \
    spel/minimal-linux.pkr.hcl
```

## Building for OpenStack

To build images for an OpenStack environment, it is necessary to pass several variables
that are specific to the environment. Also, the builders should be restricted so
as _not_ to build the Vagrant images.

```bash
source your_openstack_credentials_file.sh
packer build \
    -var 'spel_identifier=spel' \
    -var 'spel_version=0.0.1' \
    -var 'openstack_insecure=false' \
    -var 'openstack_flavor=your_flavor_name_for_temporary_instance' \
    -var 'openstack_floating_ip_network=your_provider_network_name' \
    -var 'openstack_networks=your_network_id_for_temporary_instance,second_network_id,etc.' \
    -var 'openstack_security_groups=your_security_group_name_for_temporary_instance,second_sg_name,etc.' \
    -var 'openstack_source_image_name=your_source_image_name' \
    -only 'openstack.*' \
    spel/minimal-linux.pkr.hcl
```

For expected values, see links below:
* [openstack_allow_insecure][34] (true|false)
* [openstack_flavor_name][35] (string)
* [openstack_floating_ip_network_name][36] (string)
* [openstack_network_ids][37] (comma-separated list of strings)
* [openstack_security_group_names][38] (comma-separated list of strings)
* [openstack_source_image_name][39] (string)

## Testing With AMIgen

The spel automation leverages the AMIgen8 and AMIgen9 projects as a
build-helpers for creation of EL8 and EL9 Amazon Machine Images (Azure
VM-templates, etc.), respectively.  Due to the closely-coupled nature of the
two projects, it's recommended that any changes made to AMIgen8 or AMIgen9 be
tested with spel prior to merging changes to either project's master branch.

To facilitate this testing, the following runtime-variables were added to spel:

- `amigen8_source_branch`
- `amigen8_source_url`
- `amigen9_source_branch`
- `amigen9_source_url`

Using these runtime-variables allows one to point spel to
a fork/branch of AMIgen8 or AMIgen9 during a integration-test build. To test,
update your `packer` invocation by adding elements like:

```bash
packer build \
    -var 'amigen8_source_url=https://github.com/<FORK_USER>/AMIgen8.git' \
    -var 'amigen8_source_branch=IssueNN' \
    ...
    minimal-linux.pkr.hcl
```

Similarly, these variables may be specified as environment variables by using [`PKR_VAR_<var_name>`][45]
declarations[^4] (e.g., `PKR_VAR_amigen8_source_branch`). To do so, change the
above example to:

```bash
export PKR_VAR_amigen8_source_branch="=https://github.com/<FORK_USER>/AMIgen8.git"
export PKR_VAR_amigen8_source_branch="IssueNN"

packer build \
    [...options elided...]
    minimal-linux.pkr.hcl
```



[0]: http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx
[1]: https://www.hashicorp.com/
[2]: https://www.packer.io/
[3]: https://www.packer.io/downloads.html
[4]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
[5]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment
[6]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
[7]: https://www.packer.io/docs/builders/amazon.html
[9]: https://github.com/ferricoxide/Lx-GetAMI-Utils
[10]: https://fedoraproject.org/wiki/EPEL
[11]: https://www.packer.io/docs/builders/amazon-ebs.html
[12]: https://www.virtualbox.org/wiki/Downloads
[13]: https://www.vagrantup.com/downloads.html
[14]: https://www.packer.io/docs/builders/vmware-iso.html
[15]: https://www.vmware.com/products/fusion/overview.html
[16]: https://www.vmware.com/products/workstation/overview.html
[17]: https://www.vmware.com/products/player/
[18]: https://www.packer.io/docs/builders/virtualbox-iso.html
[19]: https://vagrantcloud.com/help/
[20]: https://vagrantcloud.com/help/user-accounts/authentication
[21]: https://vagrantcloud.com/account/new
[22]: https://www.packer.io/docs/builders/azure.html
[23]: https://www.packer.io/docs/builders/azure-setup.html
[24]: https://www.packer.io/docs/builders/azure-setup.html#manual-setup
[25]: https://www.packer.io/docs/builders/azure-setup.html#guided-setup
[26]: https://azure.microsoft.com/en-us/services/managed-disks/
[27]: https://github.com/Azure/WALinuxAgent
[28]: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-centos#centos-70
[29]: https://github.com/Azure/WALinuxAgent/issues/760
[30]: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-features
[31]: https://github.com/plus3it/AMIgen7
[32]: https://github.com/plus3it/AMIgen7/blob/master/Docs/README_CustomPartitioning.md
[33]: https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
[34]: https://www.packer.io/docs/builders/openstack#insecure
[35]: https://www.packer.io/docs/builders/openstack#flavor
[36]: https://www.packer.io/docs/builders/openstack#floating_ip_network
[37]: https://www.packer.io/docs/builders/openstack#networks
[38]: https://www.packer.io/docs/builders/openstack#security_groups
[39]: https://www.packer.io/docs/builders/openstack#source_image_name
[40]: https://github.com/plus3it/amigen8
[41]: https://www.oracle.com/linux/
[42]: https://rockylinux.org/
[43]: https://almalinux.org/
[44]: https://www.suse.com/products/suse-liberty-linux/
[45]: https://developer.hashicorp.com/packer/guides/hcl/variables#from-environment-variables
[46]: https://github.com/plus3it/spel/issues/new
[47]: https://github.com/plus3it/amigen9

[^1]: Because spel is primarily an execution-wrapper for the AMIgenN projects, the "read the source" method for determining why things have changed from one spel-release to the next may require reviewing those projects' repositories
[^2]: The default-user is a local user (i.e., managed in `/etc/passwd`/`/etc/shadow`/`/etc/group`) that is dynamically-created at initial system-boot &ndash; using either the default-information in the `/etc/cloud/cloud.cfg` file or as overridden in a userData payload's `#cloud-config` content. Typically this user's `${HOME}/.ssh/authorized_keys` file is prepopulated with a provisioner's public SSH key.
[^3]: Overriding attributes of the default-user _must_ be done within a `#cloud-config` directive-block. If your userData is currently bare BASH (etc.), it will be necessary to format your userData payload as mixed, multi-part MIME.
[^4]: Use of the `PKR_VAR_` method is recommended for setting up CI/CD frameworks for producing AMIs and other supported VM-templates
