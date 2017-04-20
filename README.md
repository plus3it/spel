# spel

STIG-Partitioned Enterprise Linux (_spel_) is a project that helps create and
publish Enterprise Linux images that are partitioned according to the [DISA
STIG][0]. The resulting images also use LVM to simplify volume management. The
images are configured with help from the scripts and packages in the
[`AMIgen6`][8] and [`Lx-GetAMI-Utils`][9] projects.

## Current Published Images

RPM Manifests for published images are available in the [manifests](manifests)
directory.

| AMI Name                                         | AMI ID       | AWS Region    |
|--------------------------------------------------|--------------|---------------|
| spel-minimal-rhel-7.3-hvm-2017.04.2.x86_64-gp2   | ami-44019152 | us-east-1     |
| spel-minimal-rhel-6.9-hvm-2017.04.2.x86_64-gp2   | ami-5801914e | us-east-1     |
| spel-minimal-centos-7.3-hvm-2017.04.2.x86_64-gp2 | ami-25029233 | us-east-1     |
| spel-minimal-centos-6.9-pvm-2017.04.2.x86_64-gp2 | ami-7e009068 | us-east-1     |
| spel-minimal-centos-6.9-hvm-2017.04.2.x86_64-gp2 | ami-081e8e1e | us-east-1     |
| spel-minimal-rhel-7.3-hvm-2017.04.2.x86_64-gp2   | ami-676f4802 | us-east-2     |
| spel-minimal-rhel-6.9-hvm-2017.04.2.x86_64-gp2   | ami-b26f48d7 | us-east-2     |
| spel-minimal-centos-7.3-hvm-2017.04.2.x86_64-gp2 | ami-b36f48d6 | us-east-2     |
| spel-minimal-centos-6.9-pvm-2017.04.2.x86_64-gp2 | ami-27614642 | us-east-2     |
| spel-minimal-centos-6.9-hvm-2017.04.2.x86_64-gp2 | ami-25614640 | us-east-2     |
| spel-minimal-rhel-7.3-hvm-2017.04.2.x86_64-gp2   | ami-c16145a1 | us-west-1     |
| spel-minimal-rhel-6.9-hvm-2017.04.2.x86_64-gp2   | ami-61614501 | us-west-1     |
| spel-minimal-centos-7.3-hvm-2017.04.2.x86_64-gp2 | ami-7e67431e | us-west-1     |
| spel-minimal-centos-6.9-pvm-2017.04.2.x86_64-gp2 | ami-fd61459d | us-west-1     |
| spel-minimal-centos-6.9-hvm-2017.04.2.x86_64-gp2 | ami-76604416 | us-west-1     |
| spel-minimal-rhel-7.3-hvm-2017.04.2.x86_64-gp2   | ami-f98a1799 | us-west-2     |
| spel-minimal-rhel-6.9-hvm-2017.04.2.x86_64-gp2   | ami-12861b72 | us-west-2     |
| spel-minimal-centos-7.3-hvm-2017.04.2.x86_64-gp2 | ami-9c8518fc | us-west-2     |
| spel-minimal-centos-6.9-pvm-2017.04.2.x86_64-gp2 | ami-648a1704 | us-west-2     |
| spel-minimal-centos-6.9-hvm-2017.04.2.x86_64-gp2 | ami-68871a08 | us-west-2     |
| spel-minimal-rhel-7.3-hvm-2017.04.2.x86_64-gp2   | ami-68ed6909 | us-gov-west-1 |
| spel-minimal-rhel-6.9-hvm-2017.04.2.x86_64-gp2   | ami-24ee6a45 | us-gov-west-1 |
| spel-minimal-centos-7.3-hvm-2017.04.2.x86_64-gp2 | ami-67ed6906 | us-gov-west-1 |
| spel-minimal-centos-6.9-pvm-2017.04.2.x86_64-gp2 | ami-69ed6908 | us-gov-west-1 |
| spel-minimal-centos-6.9-hvm-2017.04.2.x86_64-gp2 | ami-4bef6b2a | us-gov-west-1 |

| Atlas Name                       | Version   | Vagrant Provider |
|----------------------------------|-----------|------------------|
| plus3it/spel-minimal-centos-6.9 | 2017.04.1 | virtualbox       |

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
to [Hashicorp Atlas][19], which requires an [Atlas account][21].

## Usage

_NOTE_: In all steps below, the examples use syntax that works on Linux. If you
are running `packer` from a Windows system, simply use the appropriate syntax
for the _relative path_ to the packer template. Most important, for Windows,
use `.\` preceding the path to the template. E.g.
`.\spel\minimal-linux.json`.

1.  Clone the repository:

    ```powershell
    git clone https://github.com/plus3it/spel && cd spel
    ```

2.  Validate the template (Optional):

    ```powershell
    packer validate spel/minimal-linux.json
    ```

3.  Begin the build. This requires at least two variables,
    `spel_identifier` and `spel_version`. See the section [Packer Variables](#minimal-linux-packer-variables)
    for more details.

    _NOTE_: This will build images for _all_ the [builders defined in the
    template](#minimal-linux-packer-builders). Use `packer build --help` to
    see how to restrict the build to to a subset of the builders.

    ```powershell
    packer build \
        -var 'atlas_username=myatlasuser' \
        -var 'spel_identifier=unique-project-id' \
        -var 'spel_version=0.0.1' \
        spel/minimal-linux.json
    ```

    If building the VirtualBox or VMware images for use with Vagrant, the
    template is configured to host the resulting images with [Hashicorp Atlas]
    [19]. This requires passing the variable `atlas_username` and exporting
    the environment variable [`ATLAS_TOKEN`][20].

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
    "atlas_username": "",
    "aws_region": "us-east-1",
    "spel_amigen6source": "https://github.com/ferricoxide/AMIgen6.git",
    "spel_amigen7source": "https://github.com/lorengordon/AMIgen7.git",
    "spel_amiutilsource": "https://github.com/ferricoxide/Lx-GetAMI-Utils.git",
    "spel_awsclisource": "https://s3.amazonaws.com/aws-cli",
    "spel_customreporpm": "",
    "spel_customreponame": "",
    "spel_desc_url": "https://github.com/plus3it/spel",
    "spel_epel6release": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm",
    "spel_epel7release": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
    "spel_epelrepo": "epel",
    "spel_extrarpms": "",
    "spel_identifier": "",
    "spel_version": "",
    "iso_url_centos6": "http://mirror.yellowfiber.net/centos/6.9/isos/x86_64/CentOS-6.9-x86_64-minimal.iso",
    "source_ami_centos6_hvm": "ami-bfb356d2",
    "source_ami_centos6_pvm": "ami-e2120888",
    "source_ami_centos7_hvm": "ami-650a1672",
    "source_ami_rhel6_hvm": "ami-1b05b10d",
    "source_ami_rhel7_hvm": "ami-b63769a1",
    "ssh_private_ip": "false",
    "subnet_id": "",
    "vpc_id": ""
}
```

| Variable Name         | Description                                                       |
|-----------------------|-------------------------------------------------------------------|
| `atlas_username`      | Username in Hashicorp Atlas                                       |
| `spel_identifier`     | Project ID to associate to the resulting images                   |
| `spel_version`        | Version to assign to the resulting image(s)                       |
| `spel_amigen6source`  | URL to the git repository for the `AMIGen6` project               |
| `spel_amiutilsource`  | URL to the git repository for the `Lx-GetAMI-Utils` project       |
| `spel_awsclisource`   | URL to the site hosting the file `awscli-bundle.zip`              |
| `spel_customreporpm`  | URL to a custom release RPM containing base repos                 |
| `spel_customreponame` | Name(s) of the custom yum repos (* or comma-separated)            |
| `spel_desc_url`       | URL to detailed description of AMI                                |
| `spel_epel6release`   | URL to the release RPM for the [EPEL 6][10] repo                  |
| `spel_epel6release`   | URL to the release RPM for the [EPEL 7][10] repo                  |
| `spel_epelrepo`       | Name of the epel repo (if different than "epel")                  |
| `spel_extrarpms`      | Comma-separated list of extra package/@group names to pass to yum |

All other variables in the `packer` template map directly to variables defined
in the `packer` docs for the [amazon-ebs builder][11] or the [virtualbox-iso
builder][18] or the [vmware-iso builder][14].

### Minimal Linux Packer Builders

The Minimal Linux `packer` template includes the following builders:

| Builder Name                    | Description                                                     |
|---------------------------------|-----------------------------------------------------------------|
| `minimal-centos-6.9-hvm`        | amazon-ebs builder that results in a minimal CentOS 6.9 HVM AMI |
| `minimal-centos-6.9-pvm`        | amazon-ebs builder that results in a minimal CentOS 6.9 PVM AMI |
| `minimal-rhel-6.9-hvm`          | amazon-ebs builder that results in a minimal RHEL 6.9 HVM AMI   |
| `minimal-centos-7.3-hvm`        | amazon-ebs builder that results in a minimal CentOS 7.3 HVM AMI |
| `minimal-rhel-7.3-hvm`          | amazon-ebs builder that results in a minimal RHEL 7.3 HVM AMI   |
| `minimal-centos-6.9-virtualbox` | virtualbox-iso builder that results in a minimal CentOS 6.9 OVA |
| `minimal-centos-6.9-vmware`     | vmware-iso builder that results in a minimal CentOS 6.9 OVF     |

### Minimal Linux Packer Post-Provisioners

The Minimal Linux `packer` template includes the following post-provisioners:

-   `vagrant`: The vagrant post-provisioner creates vagrant boxes from on the
`virtualbox` and `vmware` images.

-   `atlas`: The atlas post-provisioners upload the vagrant boxes to [Hashicorp
Atlas][19].

## Building for the AWS US GovCloud Region

To build images for the AWS US GovCloud region, `us-gov-west-1`, it is
necessary to pass several variables that are specific to the region. The AMIs
below have been tested and/or created in `us-gov-west-1` to work with the
_spel_ template(s). Also, the builders should be restricted so as _not_ to
build the Vagrant images.

```powershell
packer build \
    -var 'spel_identifier=unique-project-id' \
    -var 'spel_version=0.0.1' \
    -var 'aws_region=us-gov-west-1' \
    -var 'source_ami_centos6_hvm=ami-03bb0462' \
    -var 'source_ami_centos6_pvm=ami-62b70803' \
    -var 'source_ami_rhel6_hvm=ami-caee51ab' \
    -except 'minimal-centos-6.9-virtualbox,minimal-centos-6.9-vmware' \
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
[19]: https://atlas.hashicorp.com/help
[20]: https://atlas.hashicorp.com/help/user-accounts/authentication
[21]: https://atlas.hashicorp.com/account/new
