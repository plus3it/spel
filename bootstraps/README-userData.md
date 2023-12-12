The `builder-userData.tpl` file is built to allow the injection of key data
into a userData payload. The supported customizable-values are:

* `BOOTDEVSZ_SUBST`: Customize the size of the /boot partition &ndash; specify
  as an integer, GiB units assumed
* `BOOTLBL_SUBST`: Filesystem-label to apply to the `/boot` partition
* `BRANCH_SUBST`: Branch of the AMIgen9 project-content
* `CFNBOOTSTRAP_SUBST`: URL to download the cfn-bootstrap content from
* `CLIV2SOURCE_SUBST`: URL to download the AWS CLIv2 content from
* `FSTYP_SUBST`: Filesystem-type (typically `xfs`) of the AMI's root filesystems
* `SOURCE_SUBST`: URL hosting the AMIgen9 project-content
* `SSMAGENT_SUBST`: URL to download the AWS SSM-Manager content from
* `UEFILBL_SUBST`: Filesystem-lable to apply to the `/boot/efi` partition
  (specify in all-caps)

The bootstrap script reads in the template file, modifying its content based on
the above substitution-variables. The modified template file is then written
out as `builder-userData.runtime` to the same directory hosting the
`builder-userData.tpl` file. The bootstrap script then supplies this
written-out file as a userData payload to the EC2 that will be used to create
the final Amazon Machine Image from.
