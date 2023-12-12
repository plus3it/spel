# Background

The contents of this directory are meant as a temporary workaround to an 
upstream technical problem. It was discovered that there was a bug in RHEL 9 
and related distros that prevented the build-method used for building RHEL 6, 
RHEL 7 and RHEL 8 (and related distros) Amazon Machine Images and Azure VM 
templates from working for RHEL 9 (and related distros).

Specifically, spel uses a build-mechanism that relies on the Linux 
[`pivot_root`](https://man7.org/linux/man-pages/man2/pivot_root.2.html) 
capability to allow the build-host's root-disk to be reformatted on the fly and 
re-used as a build-target. However, Red Hat 9 (and related distros) currently 
have a bug where the kernel never _fully_ releases its boot-disk. As a result, 
attempts to rewrite the boot-disk's partition-table "on the fly" fail with an 
error similar to:

~~~
Error: Partition(s) 4 on /dev/nvme0n1 have been written, but we have been unable to inform the kernel of the change, probably because it/they are in use.  As a result, the old partition(s) will remain in use.  You should reboot now before making further changes.
~~~

## Workflow

This directory's contents change the build method to use a workflow of:

1. Create a "dummy" security group (needed for the provisioning-EC2)
1. Launch a two-disk EC2 with a self-provisioning userData payload. This
  payload:
    1. Downloads the AMIgen9 automation
    2. Installs AMIgen9 automation's RPM-dependencies
    3. Executes the AMIgen9 automation to build a EL9 OS onto the EC2's
      secondary EBS
    4. Shuts off the EC2
1. Detach the two EBS volumes from the provisioning-EC2
1. Re-attaches the secondary EBS volume as the provisioning-EC2's boot-disk
1. Registerers the provisioning-EC2 as an AMI
1. Cleans up all AWS resources created to support the registration of a new AMI
1. Sets the new AMI's permissions to public
1. Sets the new AMI's deprecation-date to one year from its creation-date

## Usage

This directory's contents consist of two main files:

* `bootstrap-el9.sh`: The script that implements the above workflow
* `builder-userData.tpl`: A templated user-data file. See the associated
  [README](README-execution.md) for details

It's primarily expected that the `bootstrap-el9.sh` script will be executed from an EC2 or similar, AWS-hosted resource. However, the script _does_ support local execution.

In either usage-scenario, it will be necessary for the script to have the AWS CLI tools available to it and a rights-profile configured that allows the automation to:

* create subnets
* delete subnets
* launch EC2s
* delete EC2s
* detach EBS volumes from EC2s
* attach EBS volumes to EC2s
* register Amazon Machine Images
* alter attributes on Amazon Machine Images

The build-EC2 will need to have network access to be able to fetch the AMIgen9 automation, whether the cardinal, GitHub-hosted project, a GitHub-hosted fork or branch or a private mirror of that code.

The following values may be specified to tweak the builder-script's behavior:

* `AMIGEN9_DESCRIPTION_STRING`: This is the value that will be assigned to the
  resulting AMI's `description` attribute (default: `STIG-partitioned [*NOT
  HARDENED*], LVM-enabled, "minimal" RHEL 9 AMI with updates through
  <TODAY_IN_YYYY-MM-DD>.  Default username 'maintuser'.  See https://github.com/plus3it/spel` )
* `SPEL_IDENTIFIER`: This is the prefix of the AMI's `name` attribute (default:
  `spel-minimal-rhel-9-hvm`)
* `SPEL_AMI_PERMISSIONS`: Whether image should be public or not (default:
  `public`)
* `SPEL_VERSION`: A version-suffix to write as part of the AMI's `name` 
  attribute (default: `0.0.0`)
* `AMIGEN9_BOOTSTRAP_AMI`: AMI ID of a machine to launch build-EC2 from (note: 
  this "bootstrap" AMI will determine whether attributes like UEFI of
  `billingProduct` codes are attached to the resultant AMI)
* `SPEL_INSTANCE_TYPE`: the instance-type of the build-EC2. The instance-type
  effects how quickly the build happens and compute-charges incurred during the
  build-EC2's run-time (default: `t3.large` - override with any Nitro-based
  instance-type of size `large` or greater)

### Local Execution

To build from a local (i.e., not hosted in AWS) system, invoke the script similarly to:

~~~
export SPEL_HOSTING_ENVIRONMENT=local
export SPEL_AWS_REGION=<AWS_REGION>
export SPEL_VERSION=<VERSION_STRING>
export BOOTSTRAP_AMI=<ID_OF_BOOTSTRAP_AMI>
export SPEL_VPC_ID=<VPC_ID_OF_BUILD_NETWORK>
export SPEL_SUBNET=<SUBNET_ID_WITHIN_BUILD_NETWORK>
bash /<FULLY_QUALIFIED_PATH_TO>/bootstrap-el9.sh
~~~

### AWS Execution

Assuming all privileges are correctly provided, the provisioning EC2 can automatically calculate the necessary values for:

* `AWS_REGION`
* `ID_OF_BOOTSTRAP_AMI`
* `VPC_ID_OF_BUILD_NETWORK`
* `SUBNET_ID_WITHIN_BUILD_NETWORK`

While these values may also be specified within the host that launches bootstrap script, those values will act as overrides to what the provisioning-EC2 would have calculated
