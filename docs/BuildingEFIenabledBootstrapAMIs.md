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

    - https://github.com/plus3it/spel
    - https://github.com/plus3it/AMIgen8
    - https://github.com/plus3it/AMIgen9

    The above assumes that your EC2 has clone access to GitHub-hosted resources. If this is not the case, it will be necessary to have mirrors of the above repos that _are_ `git`-reachable from your EC2.
5.
