# spel

STIG-Partitioned Enterprise Linux (_spel_) is a project that helps create and
publish Enterprise Linux images that are partitioned according to the
[DISA STIG][0]. The resulting images also use LVM to simplify volume management.
The images are configured with help from the scripts and packages in the
[`AMIgen6`][8], [`AMIgen7`][31], and [`Lx-GetAMI-Utils`][9] projects.

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

## Current Published Image

The AMI table below contains links to the AWS Console that search for the build
by AMI Name and sort the result by creation date. The most recent AMI of each
build will be at the top when viewed in the AWS Console.

RPM Manifests for published images are available in the [manifests](manifests)
directory.

| AWS Region    | Builder Name / Link               |
|---------------|-----------------------------------|
| us-east-1     | [spel-minimal-rhel-7-hvm][1000]   |
|               | [spel-minimal-rhel-6-hvm][1001]   |
|               | [spel-minimal-centos-7-hvm][1002] |
|               | [spel-minimal-centos-6-pvm][1003] |
|               | [spel-minimal-centos-6-hvm][1004] |
| us-east-2     | [spel-minimal-rhel-7-hvm][1005]   |
|               | [spel-minimal-rhel-6-hvm][1006]   |
|               | [spel-minimal-centos-7-hvm][1007] |
|               | [spel-minimal-centos-6-pvm][1008] |
|               | [spel-minimal-centos-6-hvm][1009] |
| us-west-1     | [spel-minimal-rhel-7-hvm][1010]   |
|               | [spel-minimal-rhel-6-hvm][1011]   |
|               | [spel-minimal-centos-7-hvm][1012] |
|               | [spel-minimal-centos-6-pvm][1013] |
|               | [spel-minimal-centos-6-hvm][1014] |
| us-west-2     | [spel-minimal-rhel-7-hvm][1015]   |
|               | [spel-minimal-rhel-6-hvm][1016]   |
|               | [spel-minimal-centos-7-hvm][1017] |
|               | [spel-minimal-centos-6-pvm][1018] |
|               | [spel-minimal-centos-6-hvm][1019] |
| us-gov-west-1 | [spel-minimal-rhel-7-hvm][1020]   |
|               | [spel-minimal-rhel-6-hvm][1021]   |
|               | [spel-minimal-centos-7-hvm][1022] |
|               | [spel-minimal-centos-6-pvm][1023] |
|               | [spel-minimal-centos-6-hvm][1024] |

| Vagrant Cloud Name                    | Vagrant Provider |
|---------------------------------------|------------------|
| [plus3it/spel-minimal-centos-6][2000] | virtualbox       |
| [plus3it/spel-minimal-centos-7][2001] | virtualbox       |

[1000]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1001]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1002]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1003]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-pvm-.*x86_64-gp2;sort=desc:creationDate>
[1004]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1005]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1006]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1007]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1008]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-pvm-.*x86_64-gp2;sort=desc:creationDate>
[1009]: <https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1010]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1011]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1012]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1013]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-pvm-.*x86_64-gp2;sort=desc:creationDate>
[1014]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1015]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1016]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-rhel-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1017]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1018]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-pvm-.*x86_64-gp2;sort=desc:creationDate>
[1019]: <https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=701759196663;name=spel-minimal-centos-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1020]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-rhel-7-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1021]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-rhel-6-hvm-.*x86_64-gp2;sort=desc:creationDate>
[1022]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-7-hvm-*x86_64-gp2;sort=desc:creationDate>
[1023]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-6-pvm-*x86_64-gp2;sort=desc:creationDate>
[1024]: <https://console.amazonaws-us-gov.com/ec2/v2/home?region=us-gov-west-1#Images:visibility=public-images;ownerAlias=039368651566;name=spel-minimal-centos-6-hvm-*x86_64-gp2;sort=desc:creationDate>

[2000]: <https://app.vagrantup.com/plus3it/boxes/spel-minimal-centos-6>
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

2.  If building the AMIs for Amazon Web Services, ensure your [AWS credentials
    are configured][4]. You do not really need the `aws` cli utility, but it is
    a convenient way to configure the credential file. You can also export the
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
    packer validate spel/minimal-linux.json
    ```

3.  Begin the build. This requires at least two variables,
    `spel_identifier` and `spel_version`. See the section [Packer Variables](#minimal-linux-packer-variables)
    for more details.

    _NOTE_: This will build images for _all_ the [builders defined in the
    template](#minimal-linux-packer-builders). Use `packer build --help` to
    see how to restrict the build to to a subset of the builders.

    ```bash
    packer build \
        -var 'vagrantcloud_username=myvagrantclouduser' \
        -var 'spel_identifier=unique-project-id' \
        -var 'spel_version=0.0.1' \
        spel/minimal-linux.json
    ```

    If building the VirtualBox or VMware images for use with Vagrant, the
    template is configured to host the resulting images with
    [Hashicorp Vagrant Cloud][19]. This requires passing the variable
    `vagrantcloud` and exporting the environment variable
    [`VAGRANTCLOUD_TOKEN`][20].

## Minimal Linux Packer Template

The Minimal Linux template builds STIG-partitioned images with a set of
packages that correspond to the "Minimal" install option in Anaconda. Further,
the AWS images include a handful of additional packages that are intended to
increase functionality in EC2 and make the images more comparable with Amazon
Linux.

-   _Template Path_: `spel/minimal-linux.json`

### Minimal Linux Packer Variables

The Minimal Linux `packer` template supports the following user variables (and
defaults):

```json
"variables": {
    "ami_force_deregister": "false",
    "ami_groups": "",
    "ami_regions": "",
    "ami_users": "",
    "vagrantcloud_username": "",
    "vagrantcloud_token": "{{env `VAGRANTCLOUD_TOKEN`}}",
    "aws_region": "us-east-1",
    "spel_amigen6source": "https://github.com/plus3it/AMIgen6.git",
    "spel_amigen7source": "https://github.com/plus3it/AMIgen7.git",
    "spel_amiutilsource": "https://github.com/ferricoxide/Lx-GetAMI-Utils.git",
    "spel_awsclisource": "https://s3.amazonaws.com/aws-cli",
    "spel_customreporpm6": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm",
    "spel_customreporpm7": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
    "spel_customreponame6": "",
    "spel_customreponame7": "",
    "spel_disablefips": "",
    "spel_desc_url": "https://github.com/plus3it/spel",
    "spel_epel6release": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm",
    "spel_epel7release": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
    "spel_epelrepo": "epel",
    "spel_extrarpms": "python34",
    "spel_identifier": "",
    "spel_version": "",
    "iso_url_centos6": "http://mirror.yellowfiber.net/centos/6.9/isos/x86_64/CentOS-6.9-x86_64-minimal.iso",
    "source_ami_centos6_hvm": "ami-bfb356d2",
    "source_ami_centos6_pvm": "ami-e2120888",
    "source_ami_centos7_hvm": "ami-650a1672",
    "source_ami_rhel6_hvm": "ami-1b05b10d",
    "source_ami_rhel7_hvm": "ami-cdc999b6",
    "ssh_private_ip": "false",
    "subnet_id": "",
    "vpc_id": ""
}
```

| Variable Name           | Description                                                       |
|-------------------------|-------------------------------------------------------------------|
| `vagrantcloud_username` | Username in Hashicorp Vagrant Cloud                               |
| `vagrantcloud_token`    | Authentication token for Vagrant Cloud (env: VAGRANTCLOUD_TOKEN)  |
| `spel_identifier`       | Project ID to associate to the resulting images                   |
| `spel_version`          | Version to assign to the resulting image(s)                       |
| `spel_amigen6source`    | URL to the git repository for the `AMIGen6` project               |
| `spel_amigen7source`    | URL to the git repository for the `AMIGen7` project               |
| `spel_amiutilsource`    | URL to the git repository for the `Lx-GetAMI-Utils` project       |
| `spel_awsclisource`     | URL to the site hosting the file `awscli-bundle.zip`              |
| `spel_customreporpm6`   | URL to a custom release RPM containing base repos for EL6         |
| `spel_customreporpm7`   | URL to a custom release RPM containing base repos for EL7         |
| `spel_customreponame6`  | Name(s) of the custom yum repos (* or comma-separated) for EL6    |
| `spel_customreponame7`  | Name(s) of the custom yum repos (* or comma-separated) for EL7    |
| `spel_disablefips`      | Flag that disables FIPS in EL7 AMIs                               |
| `spel_desc_url`         | URL to detailed description of AMI                                |
| `spel_epel6release`     | URL to the release RPM for the [EPEL 6][10] repo                  |
| `spel_epel7release`     | URL to the release RPM for the [EPEL 7][10] repo                  |
| `spel_epelrepo`         | Name of the epel repo (if different than "epel")                  |
| `spel_extrarpms`        | Comma-separated list of extra package/@group names to pass to yum |

All other variables in the `packer` template map directly to variables defined
in the `packer` docs for the [amazon-ebs builder][11] or the [virtualbox-iso
builder][18] or the [vmware-iso builder][14].

### Minimal Linux Packer Builders

The Minimal Linux `packer` template includes the following builders:

| Builder Name                     | Description                                                 |
|----------------------------------|-------------------------------------------------------------|
| `minimal-centos-6-hvm`         | amazon-ebs builder that results in a minimal CentOS 6 HVM AMI |
| `minimal-centos-6-pvm`         | amazon-ebs builder that results in a minimal CentOS 6 PVM AMI |
| `minimal-rhel-6-hvm`           | amazon-ebs builder that results in a minimal RHEL 6 HVM AMI   |
| `minimal-centos-7-hvm`         | amazon-ebs builder that results in a minimal CentOS 7 HVM AMI |
| `minimal-rhel-7-hvm`           | amazon-ebs builder that results in a minimal RHEL 7 HVM AMI   |
| `minimal-centos-6-virtualbox`  | virtualbox-iso builder that results in a minimal CentOS 6 OVA |
| `minimal-centos-6-vmware`      | vmware-iso builder that results in a minimal CentOS 6 OVF     |
| `minimal-centos-7-azure-vhd`   | azure-arm builder that results in a minimal CentOS 7 VHD      |
| `minimal-centos-7-azure-image` | azure-arm builder that results in a minimal CentOS 7 Image    |

### Minimal Linux Packer Post-Provisioners

The Minimal Linux `packer` template includes the following post-provisioners:

-   `vagrant`: The vagrant post-provisioner creates vagrant boxes from on the
    `virtualbox` and `vmware` images.

-   `vagrant-cloud`: The vagrant-cloud post-provisioners upload the vagrant
    boxes to [Hashicorp Vagrant Cloud][19].

## Building for the AWS US GovCloud Region

To build images for the AWS US GovCloud region, `us-gov-west-1`, it is
necessary to pass several variables that are specific to the region. The AMIs
below have been tested and/or created in `us-gov-west-1` to work with the
_spel_ template(s). Also, the builders should be restricted so as _not_ to
build the Vagrant images.

```bash
packer build \
    -var 'spel_identifier=unique-project-id' \
    -var 'spel_version=0.0.1' \
    -var 'aws_region=us-gov-west-1' \
    -var 'source_ami_centos6_hvm=ami-03bb0462' \
    -var 'source_ami_centos6_pvm=ami-62b70803' \
    -var 'source_ami_rhel6_hvm=ami-caee51ab' \
    -except 'minimal-centos-6-virtualbox,minimal-centos-6-vmware,minimal-centos-7-azure-vhd,minimal-centos-7-azure-image' \
    spel/minimal-linux.json
```

## Building for Microsoft Azure

Azure regions may not all support [Azure Managed Disks][26] and in turn
managed VM images. Packer provides capabilities within the [Azure Resource
Manager Builder][22] for creating either a VHD or Image.

A source VHD URI or source Image Name and Resource Group is required from
which to start the SPEL Azure build. Available Azure Marketplace CentOS Images
do not currently contain or execute cloud-init, so a custom VHD or source
image of your own, configured with cloud-init, is needed.

The resultant SPEL VHD or Image will be configured to use the Azure Linux
agent, [WALinuxAgent][27] per recommended [configurations][28]. Currently, the
use of cloud-init exclusively does not enable execution/installation of [Azure
VM Extensions][30]. The below variables also disable FIPS mode in the
resultant SPEL VHD or Image. Currently the Azure Linux agent [does not support
FIPS mode][29] when utilizing Azure VM Extensions. If no plans exist to
utilize Azure VM Extensions on VMs provisioned from SPEL VHDs or Images, FIPS
mode can be enabled, but the `waagent` configuration must also be modified
accordingly.

The variables referenced in the packer builds below should be modified with
appropriate parameters for your environment. Any content between and including
the < and > characters should be replaced.

```bash
export ARM_SUBSCRIPTION_ID=<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>
export ARM_CLIENT_ID=<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>
export ARM_CLIENT_SECRET=<YourServicePrincipalSecret>
```
Building an Azure VHD
When building a SPEL VHD, the source and destination storage account must be
the same.
Resultant VHD naming is limited, the combination of spel_identifier and
spel_version must be less than 23 characters.
```bash
packer build \
    -var 'spel_identifier=unique-project-id' \
    -var 'spel_version=0.0.1' \
    -var 'spel_disablefips=true' \
    -var 'spel_extrarpms=WALinuxAgent' \
    -var 'azure_location=<azure datacenter>' \
    -var 'azure_environment=<Public or USGovernment>' \
    -var 'azure_source_vhd_centos7=https://<storageacctname>.blob.core.<corresponding azure env>.net/<container>/<vhdname>.vhd' \
    -var 'azure_dest_resource_group=<resource group short name>' \
    -var 'azure_dest_storage_account=<storage account short name>' \
    -only 'minimal-centos-7-azure-vhd' \
    spel/minimal-linux.json
```

Building an Azure Image
```bash
packer build \
    -var 'spel_identifier=unique-project-id' \
    -var 'spel_version=0.0.1' \
    -var 'spel_disablefips=true' \
    -var 'spel_extrarpms=WALinuxAgent' \
    -var 'azure_location=<azure datacenter>' \
    -var 'azure_environment=<Public or USGovernment>' \
    -var 'azure_source_image_resource_group_centos7=<resource group short name>' \
    -var 'azure_source_image_centos7=<image short name>' \
    -var 'azure_dest_resource_group=<resource group short name>' \
    -only 'minimal-centos-7-azure-image' \
    spel/minimal-linux.json
```

## TODO

-   [ ] Create a versioned vagrant box catalog and push boxes to a self-hosted
vagrant "cloud".

[0]: http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx
[1]: https://www.hashicorp.com/
[2]: https://www.packer.io/
[3]: https://www.packer.io/downloads.html
[4]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
[5]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment
[6]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
[7]: https://www.packer.io/docs/builders/amazon.html
[8]: https://github.com/ferricoxide/AMIgen6
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
[31]: https://github.com/ferricoxide/AMIgen7
