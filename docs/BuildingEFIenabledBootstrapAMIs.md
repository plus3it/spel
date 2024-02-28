Some AMI-publishers &ndash; Red Hat and Amazon are known to do so &ndash; publish EFI-enabled AMIs. Other AMI-publishers &ndash; CentOS.Org  and Oracle are both known to not do so &ndash; publish AMIs that are _not_ EFI-enabled. It is assumed that, if publishing more than one distro's AMI in a distro-family, that consistent EFI-support will be desired in resultant AMIs. The general process is a two-stage workflow to create EFI-enabled AMIs for an arbitrary collection of distro-family's AMIs. The basic process is:

1. Look for the latest-available, efi-enabled AMI from Red Hat. This can be done with a query like:

    ~~~bash
    aws ec2 describe-images \
      --owners 309956199498 \
      --filters 'Name=name,Values=RHEL-8*_HVM-*-x86_64-*-Hourly*-GP*' \
      --query 'sort_by(Images, &CreationDate)[?
          BootMode == `uefi-preferred` || BootMode == `uefi`
        ].[ImageId,Name,CreationDate,BootMode]' \
      --output table
    ~~~

    In the commercial regions, `309956199498` is the account number that publishes the official Red Hat AMIs. In the GovCloud regions, `219670896067` is the account number that publishes the official Red Hat AMIs. The above query will return a table of EFI-enabled, "official" Red Hat 8.* AMIs. The table will be chronologically-sorted by AMIs' publication-date with the most-recent AMIs at the table's bottom. Altering the above `--filters` expression's `Values` string to start with `RHEL-9*` will execute an equivalent search for Red Hat 9.x AMIs. As of this writing, that table will look like:

    ~~~bash
    --------------------------------------------------------------------------------------------------------------------------
    |                                                     DescribeImages                                                     |
    +-----------------------+-------------------------------------------------+---------------------------+------------------+
    |  [...elided... ]      |  [...elided... ]                                |  [...elided... ]          |  [...elided... ] |
    |  ami-030ea610f78de23e1|  RHEL-8.6.0_HVM-20231009-x86_64-59-Hourly2-GP2  |  2023-10-10T23:46:37.000Z |  None            |
    |  ami-0258229bf3cd8af20|  RHEL-8.1.0_HVM-20231109-x86_64-3-Hourly2-GP2   |  2023-11-09T14:32:41.000Z |  None            |
    |  ami-05e80a6a8d7eff1ad|  RHEL-8.9.0_HVM-20231101-x86_64-11-Hourly2-GP3  |  2023-11-10T12:07:44.000Z |  uefi-preferred  |
    |  ami-086c52880ba7b988d|  RHEL-8.6.0_HVM-20231114-x86_64-59-Hourly2-GP3  |  2023-11-21T16:44:39.000Z |  None            |
    |  ami-003d574bab317de3c|  RHEL-8.8.0_HVM-20231127-x86_64-3-Hourly2-GP3   |  2023-11-27T22:04:52.000Z |  None            |
    |  ami-0c26d25ec2932e467|  RHEL-8.9.0_HVM-20240103-x86_64-3-Hourly2-GP3   |  2024-01-04T15:21:18.000Z |  uefi-preferred  |
    |  ami-0f84b5ccd72fc41de|  RHEL-8.6.0_HVM-20240117-x86_64-2-Hourly2-GP3   |  2024-01-24T08:30:47.000Z |  None            |
    |  ami-0623722112688f4e1|  RHEL-8.8.0_HVM-20240123-x86_64-22-Hourly2-GP3  |  2024-01-31T04:18:33.000Z |  None            |
    |  ami-0ece155e5bd591ddf|  RHEL-8.9.0_HVM-20240213-x86_64-3-Hourly2-GP3   |  2024-02-15T04:42:55.000Z |  uefi-preferred  |
    +-----------------------+-------------------------------------------------+---------------------------+------------------+
    ~~~

2. Launch a _pre_-Nitro instance type from the desired AMI. A `t2` or `m4` of size `large` or larger is recommended. The EC2 should have a secondary EBS of 8GiB (or larger) size attached at the `/dev/sdx` attachment-point.
3. Ensure the newly-launched EC2 has the following RPMs present:

    - zip
    - unzip
    - lvm2
    - git
    - dosfstools
    - yum-utils
    - python3-pip

4. Ensure to clone the following Git Repositories into the `root` user's `${HOME}`:

    - https://github.com/plus3it/AMIgen8
    - https://github.com/plus3it/AMIgen9

    The above assumes that your EC2 has clone access to GitHub-hosted resources. If this is not the case, it will be necessary to have mirrors of the above repos that _are_ `git`-reachable from your EC2.
5. Install the cross-distro RPM signing/verification keys and `yum` repository definitions using the `Xdistro.sh` script. This will generally look like:

    ~~~bash
    XdistroSetup.sh -d <DISTRO_NAME> \
      -k <URL_FOR_RPM_CONTAINING_RPM_VALIDATION_GPG_KEYS> \
      -r <URL_FOR_RPM_CONTAINING_RPM_VALIDATION_GPG_KEYS>,<URL_FOR_RPM_CONTAINING_YUM_REPO_DEFS>,<ETC> 
    ~~~

    This will download the above RPMs to the `${HOME}/RPM/<DISTRO_NAME>` directory. See:

    - [Oracle Linux 8](Xdistro-OL8.md)
    - [CentOS Stream 8](Xdistro-CO8.md)

    For distro-specific examples.
6. Install the `${HOME}/RPM/<DISTRO_NAME>/<VALIDATION_GPG_KEYS>` RPM
   Note: Because the `<YUM_REPO_DEFS>` RPM for Oracle Linux has a naming-collision with the one published by Red Hat, it will be necessary to use `rpm2cpio`/`cpio` to unpack the RPM and then manually copy the unpacked GPG files to `/etc/pki/rpm-gpg` directory
7. Install the `${HOME}/RPM/<DISTRO_NAME>/<YUM_REPO_DEFS>` RPM
8. Use the `yum-config-manager` utility to `--disable` the `yum` repository-definitions installed by the prior step
9. Execute the AMIgen scripts, using the secondary EBS as the build target. Generically, this will look like:

    ~~~bash
    AMIgen8/DiskSetup.sh \
      -d /dev/xvdx \
      -f xfs \
      -l boot_dev \
      -L UEFI_DEV \
      -r root_dev \
      -X && \
    AMIgen8/MkChrootTree.sh \
      -d /dev/xvdx \
      -f xfs \
      --no-lvm \
      --rootlabel root_dev \
      --with-uefi && \
    AMIgen9/OSpackages.sh \
      -X \
      -a <REPO1>,<REPO2>,...,<REPOn>\
      -r /root/RPM/<DISTRO>/<CRITICAL_RPM_1>,/root/RPM/<DISTRO>/<CRITICAL_RPM_2>,...,/root/RPM/<DISTRO>/<CRITICAL_RPM_n> \
      -e <CRITICAL_RPM_1>,<CRITICAL_RPM_2>,...,<CRITICAL_RPM_n> \
      -x subscription-manager && \
    AMIgen8/AWSutils.sh \
      -c https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
      -n https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz \
      -s https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm \
      -t amazon-ssm-agent && \
    AMIgen9/PostBuild.sh \
      -f xfs \
      -X && \
    echo SUCCESS
    ~~~

    The above will partition the secondary EBS (seen by the OS as `/dev/xvdx`) into four partitions:
    
    - a 17MiB partion (#1) to hold the boot-block record
    - a 100 MiB partition (#2) to host the FAT-formatted `/boot/efi` filesystem: this filesystem will have the label `UEFI_DEV`
    - a 400 MiB partition (#3) to host the XFS-formatted `/boot` filesystem: this filesystem will have the label `boot_dev`
    - a partition allocating the rest of the EBS's free space to host the XFS-formatted `/` filesystem: this filesystem will have the label `root_dev`

    The partitioned secondary EBS will then be mounted under the `/mnt/ec2-root` filesystem-hierarchy. Once mounted the `@core` RPM-group will be installed, plus AWS tooling (AWS CLIv2, Amazon SSM agent and the CloudFormation "bootstrap" service).