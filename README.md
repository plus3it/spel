[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)

# spel

STIG-Partitioned Enterprise Linux (_spel_) is a project that helps create and
publish Enterprise Linux images that are partitioned according to the
[DISA STIG][0]. The resulting images also use LVM to simplify volume management.
The images are configured with help from the scripts and packages in the
[`AMIgen7`][31], and [`AMIgen8`][40] projects.

## Why spel

VMs' root filesystems are generally not live-repartitionable once launced from
their images. As a result, if a STIG-scan is performed against most of the
community-published images for Red Hat and CentOS, those scans will note
failures for each of the various "`${DIRECTORY}` is on its own filesystem"
tests. The images produced through this project are designed to ensure that
these particular scan-failures do not occur.

Aside from addressing the previously-noted partitioning findings, spel does
_not_ apply any STIG-related hardening. The spel-produced images are expected
to act as a better starting-point in a larger hardening process.

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

| AWS Region    | Builder Name / Link                     |
|---------------|-----------------------------------------|
| us-east-1     | [spel-minimal-rhel-7-hvm][1000]         |
|               | [spel-minimal-centos-7-hvm][1002]       |
|               | [spel-minimal-rhel-8-hvm][1027]         |
|               | [spel-minimal-centos-8stream-hvm][1039] |
| us-east-2     | [spel-minimal-rhel-7-hvm][1005]         |
|               | [spel-minimal-centos-7-hvm][1007]       |
|               | [spel-minimal-rhel-8-hvm][1029]         |
|               | [spel-minimal-centos-8stream-hvm][1040] |
| us-west-1     | [spel-minimal-rhel-7-hvm][1010]         |
|               | [spel-minimal-centos-7-hvm][1012]       |
|               | [spel-minimal-rhel-8-hvm][1031]         |
|               | [spel-minimal-centos-8stream-hvm][1041] |
| us-west-2     | [spel-minimal-rhel-7-hvm][1015]         |
|               | [spel-minimal-centos-7-hvm][1017]       |
|               | [spel-minimal-rhel-8-hvm][1033]         |
|               | [spel-minimal-centos-8stream-hvm][1042] |
| us-gov-west-1 | [spel-minimal-rhel-7-hvm][1020]         |
|               | [spel-minimal-centos-7-hvm][1022]       |
|               | [spel-minimal-rhel-8-hvm][1035]         |
|               | [spel-minimal-centos-8stream-hvm][1043] |
| us-gov-east-1 | [spel-minimal-rhel-7-hvm][1025]         |
|               | [spel-minimal-centos-7-hvm][1026]       |
|               | [spel-minimal-rhel-8-hvm][1037]         |
|               | [spel-minimal-centos-8stream-hvm][1044] |

| Vagrant Cloud Name                    | Vagrant Provider |
|---------------------------------------|------------------|
| [plus3it/spel-minimal-centos-7][2001] | virtualbox       |

## Deprecated CentOS 8 Images

With the move from CentOS 8 to CentOS Stream 8, the CentOS 8
images are deprecated. While they remain public for the moment,
they are no longer updated and the CentOS org may remove the
yum repos at their discretion.

| AWS Region    | Builder Name / Link               |
|---------------|-----------------------------------|
| us-east-1     | [spel-minimal-centos-8-hvm][1028] |
| us-east-2     | [spel-minimal-centos-8-hvm][1030] |
| us-west-1     | [spel-minimal-centos-8-hvm][1032] |
| us-west-2     | [spel-minimal-centos-8-hvm][1034] |
| us-gov-west-1 | [spel-minimal-centos-8-hvm][1036] |
| us-gov-east-1 | [spel-minimal-centos-8-hvm][1038] |

[1000]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1002]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1005]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1007]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1010]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1012]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1015]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1017]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1020]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1022]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1025]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1026]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1027]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1028]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1029]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1030]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1031]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1032]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1033]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1034]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1035]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-rhel-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1036]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1037]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-rhel-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1038]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-8-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1039]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8stream-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1040]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8stream-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1041]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8stream-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1042]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-8stream-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1043]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-8stream-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1044]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-east-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-8stream-hvm-.*x86_64-gp2;sort=desc:creationDate>

[2001]: <https://app.vagrantup.com/plus3it/boxes/spel-minimal-centos-7>

## Default username

The default username for all spel images is `maintuser`.

If you wish to change the default username at launch, you can do so via cloud-init
with userdata something like the following. Change `<USERNAME>` to your desired
value.

```yaml
#cloud-config
system_info:
  default_user:
    name: <USERNAME>
    gecos: spel default user
    lock_passwd: true
    sudo: ["ALL=(root) NOPASSWD:ALL"]
```

## Prerequisites

[`Packer`][2] by [Hashicorp][1] is used to manage the process of building
images.

1.  [Download][3] and extract `packer` for your platform. Add it to your PATH,
    if you like. On Linux, watch out for other `packer` executables with the
    same name...

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
Linux.

-   _Template Path_: `spel/minimal-linux.pkr.hcl`

<!-- BEGIN TFDOCS -->
### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_spel_identifier"></a> [spel\_identifier](#input\_spel\_identifier) | Namespace that prefixes the name of the built images | `string` | n/a | yes |
| <a name="input_spel_version"></a> [spel\_version](#input\_spel\_version) | Version appended to the name of the built images | `string` | n/a | yes |
| <a name="input_amigen7_filesystem_label"></a> [amigen7\_filesystem\_label](#input\_amigen7\_filesystem\_label) | Label for the root filesystem when creating bare partitions for EL7 images | `string` | `""` | no |
| <a name="input_amigen7_package_groups"></a> [amigen7\_package\_groups](#input\_amigen7\_package\_groups) | List of yum repo groups to install into EL7 images | `list(string)` | <pre>[<br>  "core"<br>]</pre> | no |
| <a name="input_amigen7_package_manifest"></a> [amigen7\_package\_manifest](#input\_amigen7\_package\_manifest) | File containing a list of RPMs to use as the build manifest for EL7 images | `string` | `""` | no |
| <a name="input_amigen7_repo_names"></a> [amigen7\_repo\_names](#input\_amigen7\_repo\_names) | List of yum repo names to enable in the EL7 builders and images | `list(string)` | <pre>[<br>  "spel"<br>]</pre> | no |
| <a name="input_amigen7_repo_sources"></a> [amigen7\_repo\_sources](#input\_amigen7\_repo\_sources) | List of yum package refs (names or urls to .rpm files) that install yum repo definitions in EL7 builders and images | `list(string)` | <pre>[<br>  "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",<br>  "https://spel-packages.cloudarmor.io/spel-packages/repo/spel-release-latest-7.noarch.rpm"<br>]</pre> | no |
| <a name="input_amigen7_source_branch"></a> [amigen7\_source\_branch](#input\_amigen7\_source\_branch) | Branch that will be checked out when cloning AMIgen7 | `string` | `"master"` | no |
| <a name="input_amigen7_source_url"></a> [amigen7\_source\_url](#input\_amigen7\_source\_url) | URL that will be used to clone AMIgen7 | `string` | `"https://github.com/plus3it/AMIgen7.git"` | no |
| <a name="input_amigen7_storage_layout"></a> [amigen7\_storage\_layout](#input\_amigen7\_storage\_layout) | List of colon-separated tuples (mount:name:size) that describe the desired partitions for LVM-partitioned disks on EL7 images | `list(string)` | <pre>[<br>  "/:rootVol:4",<br>  "swap:swapVol:2",<br>  "/home:homeVol:1",<br>  "/var:varVol:2",<br>  "/var/log:logVol:2",<br>  "/var/log/audit:auditVol:100%FREE"<br>]</pre> | no |
| <a name="input_amigen8_filesystem_label"></a> [amigen8\_filesystem\_label](#input\_amigen8\_filesystem\_label) | Label for the root filesystem when creating bare partitions for EL8 images | `string` | `""` | no |
| <a name="input_amigen8_package_groups"></a> [amigen8\_package\_groups](#input\_amigen8\_package\_groups) | List of yum repo groups to install into EL8 images | `list(string)` | <pre>[<br>  "core"<br>]</pre> | no |
| <a name="input_amigen8_package_manifest"></a> [amigen8\_package\_manifest](#input\_amigen8\_package\_manifest) | File containing a list of RPMs to use as the build manifest for EL8 images | `string` | `""` | no |
| <a name="input_amigen8_repo_names"></a> [amigen8\_repo\_names](#input\_amigen8\_repo\_names) | List of yum repo names to enable in the EL8 builders and EL8 images | `list(string)` | <pre>[<br>  "spel"<br>]</pre> | no |
| <a name="input_amigen8_repo_sources"></a> [amigen8\_repo\_sources](#input\_amigen8\_repo\_sources) | List of yum package refs (names or urls to .rpm files) that install yum repo definitions in EL8 builders and images | `list(string)` | <pre>[<br>  "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm",<br>  "https://spel-packages.cloudarmor.io/spel-packages/repo/spel-release-latest-8.noarch.rpm"<br>]</pre> | no |
| <a name="input_amigen8_source_branch"></a> [amigen8\_source\_branch](#input\_amigen8\_source\_branch) | Branch that will be checked out when cloning AMIgen8 | `string` | `"master"` | no |
| <a name="input_amigen8_source_url"></a> [amigen8\_source\_url](#input\_amigen8\_source\_url) | URL that will be used to clone AMIgen8 | `string` | `"https://github.com/plus3it/AMIgen8.git"` | no |
| <a name="input_amigen8_storage_layout"></a> [amigen8\_storage\_layout](#input\_amigen8\_storage\_layout) | List of colon-separated tuples (mount:name:size) that describe the desired partitions for LVM-partitioned disks on EL8 images | `list(string)` | `[]` | no |
| <a name="input_amigen_amiutils_source_url"></a> [amigen\_amiutils\_source\_url](#input\_amigen\_amiutils\_source\_url) | URL of the AMI Utils repo to be cloned using git, containing AWS utility rpms that will be installed to the AMIs | `string` | `""` | no |
| <a name="input_amigen_aws_cfnbootstrap"></a> [amigen\_aws\_cfnbootstrap](#input\_amigen\_aws\_cfnbootstrap) | URL of the tar.gz bundle containing the CFN bootstrap utilities | `string` | `"https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz"` | no |
| <a name="input_amigen_aws_cliv1_source"></a> [amigen\_aws\_cliv1\_source](#input\_amigen\_aws\_cliv1\_source) | URL of the .zip bundle containing the installer for AWS CLI v1 | `string` | `"https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"` | no |
| <a name="input_amigen_aws_cliv2_source"></a> [amigen\_aws\_cliv2\_source](#input\_amigen\_aws\_cliv2\_source) | URL of the .zip bundle containing the installer for AWS CLI v2 | `string` | `"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"` | no |
| <a name="input_amigen_build_device"></a> [amigen\_build\_device](#input\_amigen\_build\_device) | Path of the build device that will be partitioned to create the image | `string` | `"/dev/nvme0n1"` | no |
| <a name="input_amigen_extra_rpms"></a> [amigen\_extra\_rpms](#input\_amigen\_extra\_rpms) | List of package specs (rpm names or URLs to .rpm files) to install to the builders and images | `list(string)` | <pre>[<br>  "python36",<br>  "spel-release",<br>  "ec2-hibinit-agent",<br>  "ec2-instance-connect",<br>  "ec2-net-utils",<br>  "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"<br>]</pre> | no |
| <a name="input_amigen_fips_disable"></a> [amigen\_fips\_disable](#input\_amigen\_fips\_disable) | Toggles whether FIPS will be disabled in the images | `bool` | `false` | no |
| <a name="input_amigen_grub_timeout"></a> [amigen\_grub\_timeout](#input\_amigen\_grub\_timeout) | Timeout value to set in the grub config of each image | `number` | `1` | no |
| <a name="input_amigen_use_default_repos"></a> [amigen\_use\_default\_repos](#input\_amigen\_use\_default\_repos) | Modifies the behavior of `amigen_repo_names`. When true, `amigen_repo_names` are appended to the enabled repos. When false, `amigen_repo_names` are used exclusively | `bool` | `true` | no |
| <a name="input_aws_ami_groups"></a> [aws\_ami\_groups](#input\_aws\_ami\_groups) | List of groups that have access to launch the resulting AMIs. Keyword `all` will make the AMIs publicly accessible | `list(string)` | `[]` | no |
| <a name="input_aws_ami_regions"></a> [aws\_ami\_regions](#input\_aws\_ami\_regions) | List of regions to copy the AMIs to. Tags and attributes are copied along with the AMIs | `list(string)` | `[]` | no |
| <a name="input_aws_ami_users"></a> [aws\_ami\_users](#input\_aws\_ami\_users) | List of account IDs that have access to launch the resulting AMIs | `list(string)` | `[]` | no |
| <a name="input_aws_force_deregister"></a> [aws\_force\_deregister](#input\_aws\_force\_deregister) | Force deregister an existing AMI if one with the same name already exists | `bool` | `false` | no |
| <a name="input_aws_instance_type"></a> [aws\_instance\_type](#input\_aws\_instance\_type) | EC2 instance type to use while building the AMIs | `string` | `"t3.2xlarge"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Name of the AWS region in which to launch the EC2 instance to create the AMIs | `string` | `"us-east-1"` | no |
| <a name="input_aws_source_ami_filter_centos7_hvm"></a> [aws\_source\_ami\_filter\_centos7\_hvm](#input\_aws\_source\_ami\_filter\_centos7\_hvm) | Object with source AMI filters for CentOS 7 HVM builds | <pre>object({<br>    name   = string<br>    owners = list(string)<br>  })</pre> | <pre>{<br>  "name": "CentOS 7.* x86_64",<br>  "owners": [<br>    "125523088429",<br>    "701759196663",<br>    "039368651566"<br>  ]<br>}</pre> | no |
| <a name="input_aws_source_ami_filter_centos8stream_hvm"></a> [aws\_source\_ami\_filter\_centos8stream\_hvm](#input\_aws\_source\_ami\_filter\_centos8stream\_hvm) | Object with source AMI filters for CentOS Stream 8 HVM builds | <pre>object({<br>    name   = string<br>    owners = list(string)<br>  })</pre> | <pre>{<br>  "name": "CentOS Stream 8 x86_64 *",<br>  "owners": [<br>    "125523088429",<br>    "701759196663",<br>    "039368651566"<br>  ]<br>}</pre> | no |
| <a name="input_aws_source_ami_filter_rhel7_hvm"></a> [aws\_source\_ami\_filter\_rhel7\_hvm](#input\_aws\_source\_ami\_filter\_rhel7\_hvm) | Object with source AMI filters for RHEL 7 HVM builds | <pre>object({<br>    name   = string<br>    owners = list(string)<br>  })</pre> | <pre>{<br>  "name": "RHEL-7.*_HVM-*-x86_64-*-Hourly*-GP2",<br>  "owners": [<br>    "309956199498",<br>    "219670896067"<br>  ]<br>}</pre> | no |
| <a name="input_aws_source_ami_filter_rhel8_hvm"></a> [aws\_source\_ami\_filter\_rhel8\_hvm](#input\_aws\_source\_ami\_filter\_rhel8\_hvm) | Object with source AMI filters for RHEL 8 HVM builds | <pre>object({<br>    name   = string<br>    owners = list(string)<br>  })</pre> | <pre>{<br>  "name": "RHEL-8.*_HVM-*-x86_64-*-Hourly*-GP2",<br>  "owners": [<br>    "309956199498",<br>    "219670896067"<br>  ]<br>}</pre> | no |
| <a name="input_aws_ssh_interface"></a> [aws\_ssh\_interface](#input\_aws\_ssh\_interface) | Specifies method used to select the value for the host in the SSH connection | `string` | `"public_dns"` | no |
| <a name="input_aws_subnet_id"></a> [aws\_subnet\_id](#input\_aws\_subnet\_id) | ID of the subnet where Packer will launch the EC2 instance. Required if using an non-default VPC | `string` | `null` | no |
| <a name="input_aws_temporary_security_group_source_cidrs"></a> [aws\_temporary\_security\_group\_source\_cidrs](#input\_aws\_temporary\_security\_group\_source\_cidrs) | List of IPv4 CIDR blocks to be authorized access to the instance | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_azure_build_resource_group_name"></a> [azure\_build\_resource\_group\_name](#input\_azure\_build\_resource\_group\_name) | Existing resource group in which the build will run | `string` | `null` | no |
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Application ID of the AAD Service Principal. Requires either client\_secret, client\_cert\_path or client\_jwt to be set as well | `string` | `null` | no |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | Password/secret registered for the AAD Service Principal | `string` | `null` | no |
| <a name="input_azure_cloud_environment_name"></a> [azure\_cloud\_environment\_name](#input\_azure\_cloud\_environment\_name) | One of Public, China, Germany, or USGovernment. Defaults to Public. Long forms such as USGovernmentCloud and AzureUSGovernmentCloud are also supported | `string` | `"Public"` | no |
| <a name="input_azure_custom_managed_image_name_centos7"></a> [azure\_custom\_managed\_image\_name\_centos7](#input\_azure\_custom\_managed\_image\_name\_centos7) | Name of a custom managed image to use as the base image for CentOS7 builds | `string` | `null` | no |
| <a name="input_azure_custom_managed_image_name_rhel7"></a> [azure\_custom\_managed\_image\_name\_rhel7](#input\_azure\_custom\_managed\_image\_name\_rhel7) | Name of a custom managed image to use as the base image for RHEL7 builds | `string` | `null` | no |
| <a name="input_azure_custom_managed_image_resource_group_name_centos7"></a> [azure\_custom\_managed\_image\_resource\_group\_name\_centos7](#input\_azure\_custom\_managed\_image\_resource\_group\_name\_centos7) | Name of the resource group for the custom image in `azure_custom_managed_image_name_centos7` | `string` | `null` | no |
| <a name="input_azure_custom_managed_image_resource_group_name_rhel7"></a> [azure\_custom\_managed\_image\_resource\_group\_name\_rhel7](#input\_azure\_custom\_managed\_image\_resource\_group\_name\_rhel7) | Name of the resource group for the custom image in `azure_custom_managed_image_name_rhel7` | `string` | `null` | no |
| <a name="input_azure_image_offer"></a> [azure\_image\_offer](#input\_azure\_image\_offer) | Name of the publisher offer to use for your base image (Azure Marketplace Images only) | `string` | `null` | no |
| <a name="input_azure_image_publisher"></a> [azure\_image\_publisher](#input\_azure\_image\_publisher) | Name of the publisher to use for your base image (Azure Marketplace Images only) | `string` | `null` | no |
| <a name="input_azure_image_sku"></a> [azure\_image\_sku](#input\_azure\_image\_sku) | SKU of the image offer to use for your base image (Azure Marketplace Images only) | `string` | `null` | no |
| <a name="input_azure_keep_os_disk"></a> [azure\_keep\_os\_disk](#input\_azure\_keep\_os\_disk) | Boolean toggle whether to keep the managed disk or delete it after packer runs | `bool` | `false` | no |
| <a name="input_azure_location"></a> [azure\_location](#input\_azure\_location) | Azure datacenter in which your VM will build | `string` | `null` | no |
| <a name="input_azure_managed_image_resource_group_name"></a> [azure\_managed\_image\_resource\_group\_name](#input\_azure\_managed\_image\_resource\_group\_name) | Resource group name where the result of the Packer build will be saved. The resource group must already exist | `string` | `null` | no |
| <a name="input_azure_private_virtual_network_with_public_ip"></a> [azure\_private\_virtual\_network\_with\_public\_ip](#input\_azure\_private\_virtual\_network\_with\_public\_ip) | Boolean toggle whether a public IP will be assigned when using `azure_virtual_network_name` | `bool` | `null` | no |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | n/a | `string` | `null` | no |
| <a name="input_azure_virtual_network_name"></a> [azure\_virtual\_network\_name](#input\_azure\_virtual\_network\_name) | Name of a pre-existing virtual network in which to run the build | `string` | `null` | no |
| <a name="input_azure_virtual_network_resource_group_name"></a> [azure\_virtual\_network\_resource\_group\_name](#input\_azure\_virtual\_network\_resource\_group\_name) | Name of the virtual network resource group in which to run the build | `string` | `null` | no |
| <a name="input_azure_virtual_network_subnet_name"></a> [azure\_virtual\_network\_subnet\_name](#input\_azure\_virtual\_network\_subnet\_name) | Name of the subnet in which to run the build | `string` | `null` | no |
| <a name="input_azure_vm_size"></a> [azure\_vm\_size](#input\_azure\_vm\_size) | n/a | `string` | `"Standard_DS5_v2"` | no |
| <a name="input_openstack_flavor"></a> [openstack\_flavor](#input\_openstack\_flavor) | ID, name, or full URL for the desired flavor for the server to be created | `string` | `null` | no |
| <a name="input_openstack_floating_ip_network_name"></a> [openstack\_floating\_ip\_network\_name](#input\_openstack\_floating\_ip\_network\_name) | ID or name of an external network that can be used for creation of a new floating IP | `string` | `null` | no |
| <a name="input_openstack_insecure"></a> [openstack\_insecure](#input\_openstack\_insecure) | Boolean whether the connection to OpenStack can be done over an insecure connection | `bool` | `false` | no |
| <a name="input_openstack_networks"></a> [openstack\_networks](#input\_openstack\_networks) | List of networks by UUID to attach to this instance | `list(string)` | `[]` | no |
| <a name="input_openstack_security_groups"></a> [openstack\_security\_groups](#input\_openstack\_security\_groups) | List of security groups by name to add to this instance | `list(string)` | `[]` | no |
| <a name="input_openstack_source_image_name"></a> [openstack\_source\_image\_name](#input\_openstack\_source\_image\_name) | Name of the base image to use | `string` | `null` | no |
| <a name="input_spel_description_url"></a> [spel\_description\_url](#input\_spel\_description\_url) | URL included in the AMI description | `string` | `"https://github.com/plus3it/spel"` | no |
| <a name="input_spel_http_proxy"></a> [spel\_http\_proxy](#input\_spel\_http\_proxy) | Used as the value for the git config http.proxy setting in the builder nodes | `string` | `""` | no |
| <a name="input_spel_root_volume_size"></a> [spel\_root\_volume\_size](#input\_spel\_root\_volume\_size) | Size in GB of the root volume | `number` | `20` | no |
| <a name="input_spel_ssh_username"></a> [spel\_ssh\_username](#input\_spel\_ssh\_username) | Name of the user for the ssh connection to the instance. Defaults to `spel`, which is set by cloud-config userdata. If your starting image does not have `cloud-init` installed, override the default user name | `string` | `"spel"` | no |
| <a name="input_virtualbox_iso_url_centos7"></a> [virtualbox\_iso\_url\_centos7](#input\_virtualbox\_iso\_url\_centos7) | URL to the CentOS7 .iso to use for Virtualbox builds | `string` | `"http://mirror.cs.vt.edu/pub/CentOS/7/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"` | no |
| <a name="input_virtualbox_iso_url_centos8"></a> [virtualbox\_iso\_url\_centos8](#input\_virtualbox\_iso\_url\_centos8) | URL to the CentOS8 .iso to use for Virtualbox builds | `string` | `"http://mirror.cs.vt.edu/pub/CentOS/8/isos/x86_64/CentOS-8.1.1911-x86_64-dvd1.iso"` | no |
| <a name="input_virtualbox_vagrantcloud_username"></a> [virtualbox\_vagrantcloud\_username](#input\_virtualbox\_vagrantcloud\_username) | Vagrant Cloud username, used to namespace the vagrant boxes | `string` | `null` | no |

<!-- END TFDOCS -->

### Minimal Linux Packer Builders

The Minimal Linux `packer` template includes the following builders:

| Builder Name                            | Description                                               |
|-----------------------------------------|-----------------------------------------------------------|
| `amazon-ebs.minimal-centos-8stream-hvm` | amazon-ebs builder for a minimal CentOS Stream 8 HVM AMI  |
| `amazon-ebs.minimal-rhel-8-hvm`         | amazon-ebs builder for a minimal RHEL 8 HVM AMI           |
| `amazon-ebs.minimal-centos-7-hvm`       | amazon-ebs builder for a minimal CentOS 7 HVM AMI         |
| `amazon-ebs.minimal-rhel-7-hvm`         | amazon-ebs builder for a minimal RHEL 7 HVM AMI           |
| `azure-arm.minimal-centos-7-image`      | azure-arm builder for a minimal CentOS 7 Image            |
| `azure-arm.minimal-rhel-7-image`        | azure-arm builder for a minimal RHEL 7 Image              |
| `openstack.minimal-centos-7-image`      | openstack builder for a minimal CentOS 7 Image            |
| `virtualbox-iso.minimal-centos-7-image` | virtualbox-iso builder for a minimal CentOS 7 Vagrant Box |

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
    -var 'aws_source_ami_filter_centos7_hvm={name = "*-Recovery (No-LVM)-ACB-CentOS7-HVM-SRIOV_ENA", owners = ["039368651566"]}' \
    -var 'aws_source_ami_filter_centos8stream_hvm={name = "spel-bootstrap-centos-8stream-hvm-*.x86_64-gp2", owners = ["039368651566"]}' \
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
    -var 'spel_disablefips=true' \
    -var 'amigen_extra_rpms=["WALinuxAgent"]' \
    -var 'amigen_fips_disable=true' \
    -var 'amigen7_repo_names=["rhui-microsoft-azure-rhel7"]' \
    -var 'azure_image_offer=rhel-raw' \
    -var 'azure_image_publisher=RedHat' \
    -var 'azure_image_sku=7-raw' \
    -var 'azure_managed_image_resource_group_name=<resource group short name>' \
    -only 'azure-arm.minimal-rhel-7-image' \
    spel/minimal-linux.json
```

## Building for OpenStack

To build images for an OpenStack environment, it is necessary to pass several
variables that are specific to the environment. The
[CentOS 7 Generic Cloud image][33] has been tested to work with the _spel_
template(s). Also, the builders should be restricted so as _not_ to build the
Vagrant images.

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
    spel/minimal-linux.json
```

For expected values, see links below:
* [openstack_allow_insecure][34] (true|false)
* [openstack_flavor_name][35] (string)
* [openstack_floating_ip_network_name][36] (string)
* [openstack_network_ids][37] (comma-separated list of strings)
* [openstack_security_group_names][38] (comma-separated list of strings)
* [openstack_source_image_name][39] (string)

## Testing With AMIgen

The spel automation leverages the AMIgen7 project as a build-helper for creation
of Amazon Machine Images. Due to the closely-coupled nature of the two projects,
it's recommended that any changes made to AMIgen7 be tested with spel prior to
merging changes to the AMIgen master branch.

To facilitate this testing, the runtime-variable `amigen7_source_branch` was added
to spel. Using this runtime-variable, in combination with the `amigen7_source_url`
runtime-variable, allows one to point spel to a fork/branch of AMIgen7 during a
integration-test build. To test, update your `packer` invocation by adding elements
like:

```bash
packer build \
    -var 'amigen7_source_url=https://github.com/<FORK_USER>/AMIgen7.git' \
    -var 'amigen7_source_branch=IssueNN' \
    ...
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
