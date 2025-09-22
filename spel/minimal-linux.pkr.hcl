###
# Packer Plugins
###

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.3"
    }
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1"
    }
    openstack = {
      source  = "github.com/hashicorp/openstack"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.1.1"
    }
  }
}

# Guidance on naming and organizing variables
#
# Variable names are prefixed by builder, or by amigen project. Any variables
# used by many builders are prefixed with the keyword `spel`. Variables are grouped
# by their prefix. Current prefixes
# include:
#   * aws - amazon-ebs builder
#   * azure - azure-arm builder
#   * openstack - openstack builder
#   * virtualbox - virtualbox builder
#   * amigen - used across AMIgen versions ( amigen8 and amigen9)
#   * amigen8 - amigen8 only
#   * amigen9 - amigen9 only
#   * spel - everything else
#
# For variables passed to a builder argument, just apply prefix to the argument
# name. Do not "reinterpret" the argument and create a new name. E.g. for the
# argument `instance_type`, the variable name should be `aws_instance_type`.
#
# For variables used by amigen, consider what the variable is actually being applied
# to within the amigen project, and provide a descriptive name. Avoid abbreviations!
#
# Within each prefix, all variables should be sort alphabetically by name.

###
# Variables for AWS builders
###

variable "aws_ami_groups" {
  description = "List of groups that have access to launch the resulting AMIs. Keyword `all` will make the AMIs publicly accessible"
  type        = list(string)
  default     = []
}

variable "aws_ami_regions" {
  description = "List of regions to copy the AMIs to. Tags and attributes are copied along with the AMIs"
  type        = list(string)
  default     = []
}

variable "aws_ami_users" {
  description = "List of account IDs that have access to launch the resulting AMIs"
  type        = list(string)
  default     = []
}

variable "aws_instance_type" {
  description = "EC2 instance type to use while building the AMIs"
  type        = string
  default     = "t3.2xlarge"
}

variable "aws_force_deregister" {
  description = "Force deregister an existing AMI if one with the same name already exists"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "Name of the AWS region in which to launch the EC2 instance to create the AMIs"
  type        = string
  default     = "us-east-1"
}

variable "aws_source_ami_filter_al2023_hvm" {
  description = "Object with source AMI filters for Amazon Linux 2023 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "al2023-ami-minimal-*-x86_64"
    owners = [
      "amazon",
    ]
  }
}

variable "aws_source_ami_filter_alma9_hvm" {
  description = "Object with source AMI filters for Alma Linux 9 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "AlmaLinux OS 9.* x86_64-*,spel-bootstrap-alma-9*.x86_64-gp*"
    owners = [
      "679593333241", # Alma Commercial, https://wiki.almalinux.org/cloud/AWS.html#aws-marketplace
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_source_ami_filter_centos9stream_hvm" {
  description = "Object with source AMI filters for CentOS Stream 9 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "CentOS Stream 9 x86_64 *,spel-bootstrap-centos-9stream-*.x86_64-gp*"
    owners = [
      "125523088429", # CentOS Commercial, https://wiki.centos.org/Cloud/AWS
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_source_ami_filter_ol8_hvm" {
  description = "Object with source AMI filters for Oracle Linux 8 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "OL8.*-x86_64-HVM-*,spel-bootstrap-oraclelinux-8-hvm-*.x86_64-gp*,spel-bootstrap-ol-8-*.x86_64-gp*"
    owners = [
      "131827586825", # Oracle Commercial, https://blogs.oracle.com/linux/post/running-oracle-linux-in-public-clouds
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_source_ami_filter_ol9_hvm" {
  description = "Object with source AMI filters for Oracle Linux 9 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "OL9.*-x86_64-HVM-*,spel-bootstrap-oraclelinux-9-hvm-*.x86_64-gp*,spel-bootstrap-ol-9-*.x86_64-gp*"
    owners = [
      "131827586825", # Oracle Commercial, https://blogs.oracle.com/linux/post/running-oracle-linux-in-public-clouds
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_source_ami_filter_rhel8_hvm" {
  description = "Object with source AMI filters for RHEL 8 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "RHEL-8.*_HVM-*-x86_64-*-Hourly*-GP*,spel-bootstrap-rhel-8-*.x86_64-gp*"
    owners = [
      "309956199498", # Red Hat Commercial, https://access.redhat.com/solutions/15356
      "219670896067", # Red Hat GovCloud, https://access.redhat.com/solutions/15356
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_source_ami_filter_rhel9_hvm" {
  description = "Object with source AMI filters for RHEL 9 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "RHEL-9.*_HVM-*-x86_64-*-Hourly*-GP*,spel-bootstrap-rhel-9-*.x86_64-gp*"
    owners = [
      "309956199498", # Red Hat Commercial, https://access.redhat.com/solutions/15356
      "219670896067", # Red Hat GovCloud, https://access.redhat.com/solutions/15356
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_source_ami_filter_rl9_hvm" {
  description = "Object with source AMI filters for Rocky Linux 9 HVM builds"
  type = object({
    name   = string
    owners = list(string)
  })
  default = {
    name = "Rocky-9-EC2-Base-9.*-*.x86_64,spel-bootstrap-rl-9-*.x86_64-gp*"
    owners = [
      "792107900819", # Rocky Linux, https://rockylinux.org/download (search for "AWS" tag and click)
      "174003430611", # SPEL Commercial, https://github.com/plus3it/spel
      "216406534498", # SPEL GovCloud, https://github.com/plus3it/spel
    ]
  }
}

variable "aws_ssh_interface" {
  description = "Specifies method used to select the value for the host in the SSH connection"
  type        = string
  default     = "public_dns"

  validation {
    condition     = contains(["public_ip", "private_ip", "public_dns", "private_dns", "session_manager"], var.aws_ssh_interface)
    error_message = "Variable `aws_ssh_interface` must be one of: public_ip, private_ip, public_dns, private_dns, or session_manager."
  }
}

variable "aws_subnet_id" {
  description = "ID of the subnet where Packer will launch the EC2 instance. Required if using an non-default VPC"
  type        = string
  default     = null
}

variable "aws_temporary_security_group_source_cidrs" {
  description = "List of IPv4 CIDR blocks to be authorized access to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

###
# Variables for Azure builders
###

variable "azure_build_resource_group_name" {
  description = "Existing resource group in which the build will run"
  type        = string
  default     = null
}

variable "azure_client_id" {
  description = "Application ID of the AAD Service Principal. Requires either client_secret, client_cert_path or client_jwt to be set as well"
  type        = string
  default     = null
}

variable "azure_client_secret" {
  description = "Password/secret registered for the AAD Service Principal"
  type        = string
  default     = null
}

variable "azure_cloud_environment_name" {
  description = "One of Public, China, Germany, or USGovernment. Defaults to Public. Long forms such as USGovernmentCloud and AzureUSGovernmentCloud are also supported"
  type        = string
  default     = "Public"
}

variable "azure_image_offer" {
  description = "Name of the publisher offer to use for your base image (Azure Marketplace Images only)"
  type        = string
  default     = null
}

variable "azure_image_publisher" {
  description = "Name of the publisher to use for your base image (Azure Marketplace Images only)"
  type        = string
  default     = null
}

variable "azure_image_sku" {
  description = "SKU of the image offer to use for your base image (Azure Marketplace Images only)"
  type        = string
  default     = null
}

variable "azure_keep_os_disk" {
  description = "Boolean toggle whether to keep the managed disk or delete it after packer runs"
  type        = bool
  default     = false
}

variable "azure_location" {
  description = "Azure datacenter in which your VM will build"
  type        = string
  default     = null
}

variable "azure_managed_image_resource_group_name" {
  description = "Resource group name where the result of the Packer build will be saved. The resource group must already exist"
  type        = string
  default     = null
}

variable "azure_private_virtual_network_with_public_ip" {
  description = "Boolean toggle whether a public IP will be assigned when using `azure_virtual_network_name`"
  type        = bool
  default     = null
}

variable "azure_subscription_id" {
  type    = string
  default = null
}

variable "azure_virtual_network_name" {
  description = "Name of a pre-existing virtual network in which to run the build"
  type        = string
  default     = null
}

variable "azure_virtual_network_resource_group_name" {
  description = "Name of the virtual network resource group in which to run the build"
  type        = string
  default     = null
}

variable "azure_virtual_network_subnet_name" {
  description = "Name of the subnet in which to run the build"
  type        = string
  default     = null
}

variable "azure_vm_size" {
  type    = string
  default = "Standard_DS5_v2"
}

###
# Variables for Openstack builders
###

variable "openstack_insecure" {
  description = "Boolean whether the connection to OpenStack can be done over an insecure connection"
  type        = bool
  default     = false
}

variable "openstack_flavor" {
  description = "ID, name, or full URL for the desired flavor for the server to be created"
  type        = string
  default     = null
}

variable "openstack_floating_ip_network_name" {
  description = "ID or name of an external network that can be used for creation of a new floating IP"
  type        = string
  default     = null
}

variable "openstack_networks" {
  description = "List of networks by UUID to attach to this instance"
  type        = list(string)
  default     = []
}

variable "openstack_security_groups" {
  description = "List of security groups by name to add to this instance"
  type        = list(string)
  default     = []
}

variable "openstack_source_image_name" {
  description = "Name of the base image to use"
  type        = string
  default     = null
}

###
# Variables for Virtualbox/Vagrant builds
###

variable "virtualbox_iso_url_centos9stream" {
  description = "URL to the CentOS Stream 9 .iso to use for Virtualbox builds"
  type        = string
  default     = "http://mirror.facebook.net/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
}

variable "virtualbox_vagrantcloud_username" {
  description = "Vagrant Cloud username, used to namespace the vagrant boxes"
  type        = string
  default     = null
}

###
# Variables used by all AMIGEN platforms
###

variable "amigen_amiutils_source_url" {
  description = "URL of the AMI Utils repo to be cloned using git, containing AWS utility rpms that will be installed to the AMIs"
  type        = string
  default     = ""
}

variable "amigen_aws_cfnbootstrap" {
  description = "URL of the tar.gz bundle containing the CFN bootstrap utilities"
  type        = string
  default     = "https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz"
}

variable "amigen_aws_cliv1_source" {
  description = "URL of the .zip bundle containing the installer for AWS CLI v1"
  type        = string
  default     = ""
}

variable "amigen_aws_cliv2_source" {
  description = "URL of the .zip bundle containing the installer for AWS CLI v2"
  type        = string
  default     = "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
}

variable "amigen_fips_disable" {
  description = "Toggles whether FIPS will be disabled in the images"
  type        = bool
  default     = false
}

variable "amigen_grub_timeout" {
  description = "Timeout value to set in the grub config of each image"
  type        = number
  default     = 1
}

variable "amigen_use_default_repos" {
  description = "Modifies the behavior of `amigen_repo_names`. When true, `amigen_repo_names` are appended to the enabled repos. When false, `amigen_repo_names` are used exclusively"
  type        = bool
  default     = true
}

###
# Variables used by AMIgen8
###

variable "amigen8_bootdev_mult" {
  description = "Factor by which to increase /boot's size on \"special\" distros (like OL8)"
  type        = string
  default     = "1.2"
}

variable "amigen8_bootdev_size" {
  description = "Size, in MiB, to make the /boot partition (this will be multiplied by the 'amigen8_bootdev_mult' value for Oracle Linux images)"
  type        = string
  default     = "1024"
}

variable "amigen8_extra_rpms" {
  description = "List of package specs (rpm names or URLs to .rpm files) to install to the EL8 builders and images"
  type        = list(string)
  default = [
    "python39",
    "python39-pip",
    "python39-setuptools",
    "crypto-policies-scripts",
    "spel-release",
    "spel-dod-certs",
    "spel-wcf-certs",
    "ec2-hibinit-agent",
    "ec2-instance-connect",
    "ec2-instance-connect-selinux",
    "ec2-utils",
    "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm",
  ]
}

variable "amigen8_filesystem_label" {
  description = "Label for the root filesystem when creating bare partitions for EL8 images"
  type        = string
  default     = ""
}

variable "amigen8_package_groups" {
  description = "List of yum repo groups to install into EL8 images"
  type        = list(string)
  default     = ["core"]
}

variable "amigen8_package_manifest" {
  description = "File containing a list of RPMs to use as the build manifest for EL8 images"
  type        = string
  default     = ""
}

variable "amigen8_repo_names" {
  description = "List of yum repo names to enable in the EL8 builders and EL8 images"
  type        = list(string)
  default     = ["spel"]
}

variable "amigen8_repo_sources" {
  description = "List of yum package refs (names or urls to .rpm files) that install yum repo definitions in EL8 builders and images"
  type        = list(string)
  default = [
    "https://spel-packages.cloudarmor.io/spel-packages/repo/spel-release-latest-8.noarch.rpm",
  ]
}

variable "amigen8_source_branch" {
  description = "Branch that will be checked out when cloning AMIgen8"
  type        = string
  default     = "master"
}

variable "amigen8_source_url" {
  description = "URL that will be used to clone AMIgen8"
  type        = string
  default     = "https://github.com/plus3it/AMIgen8.git"
}

variable "amigen8_storage_layout" {
  description = "List of colon-separated tuples (mount:name:size) that describe the desired partitions for LVM-partitioned disks on EL8 images"
  type        = list(string)
  default = [
    "/:rootVol:6",
    "swap:swapVol:2",
    "/home:homeVol:1",
    "/var:varVol:2",
    "/var/tmp:varTmpVol:2",
    "/var/log:logVol:2",
    "/var/log/audit:auditVol:100%FREE",
  ]
}

###
# Variables used by AMIgen9
###
variable "amigen9_boot_dev_size" {
  description = "Size of the partition hosting the '/boot' partition"
  type        = number
  default     = 768
}

variable "amigen9_boot_dev_size_mult" {
  description = "Factor by which to increase /boot's size on \"special\" distros (like OL9)"
  type        = number
  default     = "1.1"
}

variable "amigen9_boot_dev_label" {
  description = "Filesystem-label to apply to the '/boot' partition"
  type        = string
  default     = "boot_disk"
}

variable "amigen9_extra_rpms" {
  description = "List of package specs (rpm names or URLs to .rpm files) to install to the EL9 builders and images"
  type        = list(string)
  default = [
    "crypto-policies-scripts",
    "spel-release",
    "spel-dod-certs",
    "spel-wcf-certs",
    "ec2-hibinit-agent",
    "ec2-utils",
    "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm",
  ]
}

variable "amigen9_filesystem_label" {
  description = "Label for the root filesystem when creating bare partitions for EL9 images"
  type        = string
  default     = ""
}

variable "amigen9_package_groups" {
  description = "List of yum repo groups to install into EL9 images"
  type        = list(string)
  default     = ["core"]
}

variable "amigen9_package_manifest" {
  description = "File containing a list of RPMs to use as the build manifest for EL9 images"
  type        = string
  default     = ""
}

variable "amigen9_package_manifest_al2023" {
  description = "File containing a list of RPMs to use as the build manifest for AL2023 images"
  type        = string
  default     = "/tmp/el-build/install-manifests/al2023-minimal.txt"
}

variable "amigen9_repo_names" {
  description = "List of yum repo names to enable in the EL9 builders and EL9 images"
  type        = list(string)
  default = [
    "spel",
  ]
}

variable "amigen9_repo_sources" {
  description = "List of yum package refs (names or urls to .rpm files) that install yum repo definitions in EL9 builders and images"
  type        = list(string)
  default = [
    "https://spel-packages.cloudarmor.io/spel-packages/repo/spel-release-latest-9.noarch.rpm",
  ]
}

variable "amigen9_source_branch" {
  description = "Branch that will be checked out when cloning AMIgen9"
  type        = string
  default     = "main"
}

variable "amigen9_source_url" {
  description = "URL that will be used to clone AMIgen9"
  type        = string
  default     = "https://github.com/plus3it/AMIgen9.git"
}

variable "amigen9_storage_layout" {
  description = "List of colon-separated tuples (mount:name:size) that describe the desired partitions for LVM-partitioned disks on EL9 images"
  type        = list(string)
  default = [
    "/:rootVol:6",
    "swap:swapVol:2",
    "/home:homeVol:1",
    "/var:varVol:2",
    "/var/tmp:varTmpVol:2",
    "/var/log:logVol:2",
    "/var/log/audit:auditVol:100%FREE",
  ]
}

variable "amigen9_uefi_dev_size" {
  description = "Size of the partition hosting the '/boot/efi' partition"
  type        = number
  default     = 128
}

variable "amigen9_uefi_dev_label" {
  description = "Filesystem-label to apply to the '/boot/efi' partition"
  type        = string
  default     = "UEFI_DISK"
}


###
# Variables used for Azure-based builds
###
variable "azure_custom_managed_image_name_rhel8" {
  description = "Name of a custom managed image to use as the base image for RHEL8 builds"
  type        = string
  default     = null
}


variable "azure_custom_managed_image_resource_group_name_rhel8" {
  description = "Name of the resource group for the custom image in `azure_custom_managed_image_name_rhel8`"
  type        = string
  default     = null
}



###
# Variables specific to spel
###

variable "spel_deprecation_lifetime" {
  description = "Duration after which image will be marked deprecated. If null, image will not be marked deprecated. The accepted units are: ns, us (or µs), ms, s, m, and h. For example, one day is 24h, and one year is 8760h."
  type        = string
  default     = null
}

variable "spel_description_url" {
  description = "URL included in the AMI description"
  type        = string
  default     = "https://github.com/plus3it/spel"
}

variable "spel_http_proxy" {
  description = "Used as the value for the git config http.proxy setting in the builder nodes"
  type        = string
  default     = ""
}

variable "spel_identifier" {
  description = "Namespace that prefixes the name of the built images"
  type        = string
}

variable "spel_root_volume_size" {
  description = "Size in GB of the root volume"
  type        = number
  default     = 20
}

variable "spel_ssh_username" {
  description = "Name of the user for the ssh connection to the instance. Defaults to `spel`, which is set by cloud-config userdata. If your starting image does not have `cloud-init` installed, override the default user name"
  type        = string
  default     = "spel"
}

variable "spel_version" {
  description = "Version appended to the name of the built images"
  type        = string
}

###
# End of variables blocks
###
# Start of source blocks
###

source "amazon-ebssurrogate" "base" {
  ami_root_device {
    source_device_name    = "/dev/xvdf"
    delete_on_termination = true
    device_name           = source.name == "minimal-amzn-2023-hvm" ? "/dev/xvda" : "/dev/sda1"
    volume_size           = var.spel_root_volume_size
    volume_type           = "gp3"
  }
  ami_groups                  = var.aws_ami_groups
  ami_name                    = "${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp3"
  ami_regions                 = var.aws_ami_regions
  ami_users                   = var.aws_ami_users
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  communicator                = "ssh"
  deprecate_at                = local.aws_ami_deprecate_at
  ena_support                 = true
  force_deregister            = var.aws_force_deregister
  instance_type               = var.aws_instance_type
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = source.name == "minimal-amzn-2023-hvm" ? "/dev/xvda" : "/dev/sda1"
    volume_size           = var.spel_root_volume_size
    volume_type           = "gp3"
  }
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvdf"
    volume_size           = var.spel_root_volume_size
    volume_type           = "gp3"
  }
  max_retries   = 20
  region        = var.aws_region
  sriov_support = true
  ssh_interface = var.aws_ssh_interface
  ssh_port      = 22
  ssh_pty       = true
  ssh_timeout   = "60m"
  ssh_username  = var.spel_ssh_username
  ssh_key_exchange_algorithms = [
    "ecdh-sha2-nistp521",
    "ecdh-sha2-nistp256",
    "ecdh-sha2-nistp384",
    "ecdh-sha2-nistp521",
    "diffie-hellman-group14-sha1",
    "diffie-hellman-group1-sha1"
  ]
  subnet_id                             = var.aws_subnet_id
  temporary_security_group_source_cidrs = var.aws_temporary_security_group_source_cidrs
  use_create_image                      = true
  user_data_file                        = "${path.root}/userdata/userdata.cloud"
}

source "azure-arm" "base" {
  build_resource_group_name              = var.azure_build_resource_group_name
  client_id                              = var.azure_client_id
  client_secret                          = var.azure_client_secret
  cloud_environment_name                 = var.azure_cloud_environment_name
  communicator                           = "ssh"
  custom_data_file                       = "${path.root}/userdata/userdata.cloud"
  image_offer                            = var.azure_image_offer
  image_publisher                        = var.azure_image_publisher
  image_sku                              = var.azure_image_sku
  keep_os_disk                           = var.azure_keep_os_disk
  location                               = var.azure_location
  managed_image_name                     = "${var.spel_identifier}-${source.name}-${var.spel_version}"
  managed_image_resource_group_name      = var.azure_managed_image_resource_group_name
  os_disk_size_gb                        = var.spel_root_volume_size
  os_type                                = "Linux"
  private_virtual_network_with_public_ip = var.azure_private_virtual_network_with_public_ip
  ssh_port                               = 22
  ssh_pty                                = true
  ssh_timeout                            = "60m"
  ssh_username                           = var.spel_ssh_username
  subscription_id                        = var.azure_subscription_id
  use_azure_cli_auth                     = true
  virtual_network_name                   = var.azure_virtual_network_name
  virtual_network_resource_group_name    = var.azure_virtual_network_resource_group_name
  virtual_network_subnet_name            = var.azure_virtual_network_subnet_name
  vm_size                                = var.azure_vm_size
}

source "openstack" "base" {
  flavor                  = var.openstack_flavor
  floating_ip_network     = var.openstack_floating_ip_network_name
  image_name              = "${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64"
  insecure                = var.openstack_insecure
  networks                = var.openstack_networks
  security_groups         = var.openstack_security_groups
  source_image_name       = var.openstack_source_image_name
  ssh_port                = 22
  ssh_timeout             = "30m"
  ssh_username            = var.spel_ssh_username
  use_blockstorage_volume = "false"
  user_data_file          = "${path.root}/userdata/userdata.cloud"
}

source "virtualbox-iso" "base" {
  boot_wait               = "10s"
  disk_size               = 20480
  format                  = "ova"
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type           = "RedHat_64"
  headless                = true
  http_directory          = "${path.root}/kickstarts"
  output_directory        = ".spel/${var.spel_version}/${var.spel_identifier}-${source.name}"
  shutdown_command        = "echo '/sbin/halt -h -p' > shutdown.sh; echo 'vagrant'|sudo -S bash 'shutdown.sh'"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "${var.spel_identifier}-${source.name}-${var.spel_version}"
}

###
# End of source blocks
###
# Start of locals block
###

locals {
  # Join lists to create strings appropriate for environment variables and AMIgen
  # expectations. AMIgen expects some vars to be comma-delimited, and others to
  # be space-delimited.
  amigen8_extra_rpms     = join(",", var.amigen8_extra_rpms)
  amigen8_package_groups = join(" ", var.amigen8_package_groups) # space-delimited
  amigen8_repo_names     = join(",", var.amigen8_repo_names)
  amigen8_repo_sources   = join(",", var.amigen8_repo_sources)
  amigen8_storage_layout = join(",", var.amigen8_storage_layout)
  amigen9_extra_rpms     = join(",", var.amigen9_extra_rpms)
  amigen9_package_groups = join(" ", var.amigen9_package_groups) # space-delimited
  amigen9_repo_names     = join(",", var.amigen9_repo_names)
  amigen9_repo_sources   = join(",", var.amigen9_repo_sources)
  amigen9_storage_layout = join(",", var.amigen9_storage_layout)

  # Template the description string
  description = "STIG-partitioned [*NOT HARDENED*], LVM-enabled, \"minimal\" %s, with updates through ${formatdate("YYYY-MM-DD", local.timestamp)}. Default username `maintuser`. See ${var.spel_description_url}."

  # Calculate AWS AMI deprecate_at timestamp
  aws_ami_deprecate_at = var.spel_deprecation_lifetime != null ? timeadd(local.timestamp, var.spel_deprecation_lifetime) : null

  timestamp = timestamp()
}

###
# End of locals block
###
# Start of build blocks
###

# AMIgen builds
build {
  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "Alma Linux 9 AMI")
    name            = "minimal-alma-9-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_alma9_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_alma9_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "Amazon Linux 2023 AMI")
    name            = "minimal-amzn-2023-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_al2023_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_al2023_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "CentOS Stream 9 AMI")
    name            = "minimal-centos-9stream-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_centos9stream_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_centos9stream_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "Oracle Linux 8 AMI")
    name            = "minimal-ol-8-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_ol8_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_ol8_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "Oracle Linux 9 AMI")
    name            = "minimal-ol-9-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_ol9_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_ol9_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "RHEL 8 AMI")
    name            = "minimal-rhel-8-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_rhel8_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_rhel8_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "RHEL 9 AMI")
    name            = "minimal-rhel-9-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_rhel9_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_rhel9_hvm.owners
      most_recent = true
    }
  }

  source "amazon-ebssurrogate.base" {
    ami_description = format(local.description, "Rocky Linux 9 AMI")
    name            = "minimal-rl-9-hvm"
    source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name                = var.aws_source_ami_filter_rl9_hvm.name
        root-device-type    = "ebs"
      }
      owners      = var.aws_source_ami_filter_rl9_hvm.owners
      most_recent = true
    }
  }

  source "azure-arm.base" {
    azure_tags = {
      Description = format(local.description, "RHEL 8 image")
    }
    custom_managed_image_name                = var.azure_custom_managed_image_name_rhel8
    custom_managed_image_resource_group_name = var.azure_custom_managed_image_resource_group_name_rhel8
    name                                     = "minimal-rhel-8-image"
  }

  # Update the rhui-azure RPM before the broader-scope `yum udate`
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E sh -ex '{{ .Path }}'"
    inline = [
      "dnf update -y --disablerepo='*' --enablerepo='*microsoft*'",
    ]
    only = [
      "azure-arm.minimal-rhel-8-image",
    ]
  }

  # Common provisioners
  provisioner "shell" {
    environment_vars = [
      "DNF_VAR_ociregion=",
      "DNF_VAR_ocidomain=oracle.com",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash -ex '{{ .Path }}'"
    inline = [
      "/usr/bin/cloud-init status --wait",
      "setenforce 0",
      "yum -y update",
    ]
  }

  # Want to try to run this pre-step early on EL9
  provisioner "shell" {
    environment_vars = [
      "DNF_VAR_ociregion=",
      "DNF_VAR_ocidomain=oracle.com",
      "SPEL_AMIGEN9SOURCE=${var.amigen9_source_url}",
      "SPEL_AMIGENREPOS=${local.amigen9_repo_names}",
      "SPEL_AMIGENREPOSRC=${local.amigen9_repo_sources}",
      "SPEL_BUILDDEPS=dosfstools git lvm2 parted python3-pip unzip yum-utils",
      "SPEL_EXTRARPMS=${local.amigen9_extra_rpms}",
      "SPEL_USEDEFAULTREPOS=${var.amigen_use_default_repos}",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/builder-prep-9.sh",
    ]
    only = [
      "amazon-ebssurrogate.minimal-alma-9-hvm",
      "amazon-ebssurrogate.minimal-centos-9stream-hvm",
      "amazon-ebssurrogate.minimal-ol-9-hvm",
      "amazon-ebssurrogate.minimal-rhel-9-hvm",
      "amazon-ebssurrogate.minimal-rl-9-hvm",
    ]
  }

  # Want to try to run this pre-step early on AL2023
  provisioner "shell" {
    environment_vars = [
      "SPEL_AMIGEN9SOURCE=${var.amigen9_source_url}",
      "SPEL_AMIGENREPOS=${local.amigen9_repo_names}",
      "SPEL_AMIGENREPOSRC=${local.amigen9_repo_sources}",
      "SPEL_BUILDDEPS=dnf-utils dosfstools git lvm2 parted python3-pip unzip",
      "SPEL_EXTRARPMS=${local.amigen9_extra_rpms}",
      "SPEL_USEDEFAULTREPOS=${var.amigen_use_default_repos}",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/builder-prep-9.sh",
    ]
    only = [
      "amazon-ebssurrogate.minimal-amzn-2023-hvm",
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DNF_VAR_ociregion=",
      "DNF_VAR_ocidomain=oracle.com",
    ]
    execute_command   = "{{ .Vars }} sudo -E /bin/sh '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "${path.root}/scripts/pivot-root.sh",
    ]
    start_retry_timeout = "15m"
    only = [
      "azure-arm.minimal-rhel-8-image",
    ]
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/free-root.sh",
    ]
    only = [
      "azure-arm.minimal-rhel-8-image",
    ]
  }

  # Keep the unmount in a separate provisioner. This forces packer to disconnect
  # and release the ssh session that would otherwise lock the target.
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E /bin/sh -ex '{{ .Path }}'"
    inline = [
      "echo Unmounting /oldroot",
      "test $( grep -c /oldroot /proc/mounts ) -eq 0 || umount /oldroot",
    ]
    only = [
      "azure-arm.minimal-rhel-8-image",
    ]
  }

  # AWS EL8 provisioners
  provisioner "shell" {
    environment_vars = [
      "DNF_VAR_ocidomain=oracle.com",
      "DNF_VAR_ociregion=",
      "SPEL_AMIGEN8SOURCE=${var.amigen8_source_url}",
      "SPEL_AMIGENBOOTDEVMULT=${var.amigen8_bootdev_mult}",
      "SPEL_AMIGENBOOTDEVSZ=${var.amigen8_bootdev_size}",
      "SPEL_AMIGENBOOTSIZE=17m",
      "SPEL_AMIGENBRANCH=${var.amigen8_source_branch}",
      "SPEL_AMIGENCHROOT=/mnt/ec2-root",
      "SPEL_AMIGENMANFST=${var.amigen8_package_manifest}",
      "SPEL_AMIGENPKGGRP=${local.amigen8_package_groups}",
      "SPEL_AMIGENREPOS=${local.amigen8_repo_names}",
      "SPEL_AMIGENREPOSRC=${local.amigen8_repo_sources}",
      "SPEL_AMIGENROOTNM=${var.amigen8_filesystem_label}",
      "SPEL_AMIGENSTORLAY=${local.amigen8_storage_layout}",
      "SPEL_AMIGENVGNAME=RootVG",
      "SPEL_AWSCFNBOOTSTRAP=${var.amigen_aws_cfnbootstrap}",
      "SPEL_AWSCLIV1SOURCE=${var.amigen_aws_cliv1_source}",
      "SPEL_AWSCLIV2SOURCE=${var.amigen_aws_cliv2_source}",
      "SPEL_CLOUDPROVIDER=aws",
      "SPEL_EXTRARPMS=${local.amigen8_extra_rpms}",
      "SPEL_FIPSDISABLE=${var.amigen_fips_disable}",
      "SPEL_GRUBTMOUT=${var.amigen_grub_timeout}",
      "SPEL_USEDEFAULTREPOS=${var.amigen_use_default_repos}",
      "SPEL_USEROOTDEVICE=false",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    only = [
      "amazon-ebssurrogate.minimal-ol-8-hvm",
      "amazon-ebssurrogate.minimal-rhel-8-hvm",
    ]
    scripts = [
      "${path.root}/scripts/amigen8-build.sh",
    ]
  }

  # AWS EL9 provisioners
  provisioner "shell" {
    environment_vars = [
      "DNF_VAR_ocidomain=oracle.com",
      "DNF_VAR_ociregion=",
      "SPEL_AMIGEN9SOURCE=${var.amigen9_source_url}",
      "SPEL_AMIGENBOOTDEVLBL=${var.amigen9_boot_dev_label}",
      "SPEL_AMIGENBOOTDEVSZ=${var.amigen9_boot_dev_size}",
      "SPEL_AMIGENBOOTDEVSZMLT=${var.amigen9_boot_dev_size_mult}",
      "SPEL_AMIGENBRANCH=${var.amigen9_source_branch}",
      "SPEL_AMIGENCHROOT=/mnt/ec2-root",
      "SPEL_AMIGENMANFST=${var.amigen9_package_manifest}",
      "SPEL_AMIGENMANFSTAL2023=${var.amigen9_package_manifest_al2023}",
      "SPEL_AMIGENPKGGRP=${local.amigen9_package_groups}",
      "SPEL_AMIGENREPOS=${local.amigen9_repo_names}",
      "SPEL_AMIGENREPOSRC=${local.amigen9_repo_sources}",
      "SPEL_AMIGENROOTNM=${var.amigen9_filesystem_label}",
      "SPEL_AMIGENSTORLAY=${local.amigen9_storage_layout}",
      "SPEL_AMIGENUEFIDEVLBL=${var.amigen9_uefi_dev_label}",
      "SPEL_AMIGENUEFIDEVSZ=${var.amigen9_uefi_dev_size}",
      "SPEL_AMIGENVGNAME=RootVG",
      "SPEL_AWSCFNBOOTSTRAP=${var.amigen_aws_cfnbootstrap}",
      "SPEL_AWSCLIV1SOURCE=${var.amigen_aws_cliv1_source}",
      "SPEL_AWSCLIV2SOURCE=${var.amigen_aws_cliv2_source}",
      "SPEL_CLOUDPROVIDER=aws",
      "SPEL_EXTRARPMS=${local.amigen9_extra_rpms}",
      "SPEL_FIPSDISABLE=${var.amigen_fips_disable}",
      "SPEL_GRUBTMOUT=${var.amigen_grub_timeout}",
      "SPEL_USEDEFAULTREPOS=${var.amigen_use_default_repos}",
      "SPEL_USEROOTDEVICE=false",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    only = [
      "amazon-ebssurrogate.minimal-alma-9-hvm",
      "amazon-ebssurrogate.minimal-amzn-2023-hvm",
      "amazon-ebssurrogate.minimal-centos-9stream-hvm",
      "amazon-ebssurrogate.minimal-ol-9-hvm",
      "amazon-ebssurrogate.minimal-rhel-9-hvm",
      "amazon-ebssurrogate.minimal-rl-9-hvm",
    ]
    scripts = [
      "${path.root}/scripts/amigen9-build.sh",
    ]
  }

  # Azure EL8 provisioners
  provisioner "shell" {
    environment_vars = [
      "SPEL_AMIGENBRANCH=${var.amigen8_source_branch}",
      "SPEL_AMIGENBUILDDEV=/dev/sda",
      "SPEL_AMIGENCHROOT=/mnt/ec2-root",
      "SPEL_AMIGENPKGGRP=${local.amigen8_package_groups}",
      "SPEL_AMIGENREPOS=${local.amigen8_repo_names}",
      "SPEL_AMIGENREPOSRC=${local.amigen8_repo_sources}",
      "SPEL_AMIGEN8SOURCE=${var.amigen8_source_url}",
      "SPEL_AMIGENSTORLAY=${local.amigen8_storage_layout}",
      "SPEL_AMIGENVGNAME=VolGroup00",
      "SPEL_AMIUTILSSOURCE=${var.amigen_amiutils_source_url}",
      "SPEL_AWSCFNBOOTSTRAP=${var.amigen_aws_cfnbootstrap}",
      "SPEL_AWSCLIV1SOURCE=${var.amigen_aws_cliv1_source}",
      "SPEL_AWSCLIV2SOURCE=${var.amigen_aws_cliv2_source}",
      "SPEL_BOOTLABEL=/boot",
      "SPEL_BUILDDEPS=lvm2 parted yum-utils unzip git",
      "SPEL_BUILDNAME=${source.name}",
      "SPEL_CLOUDPROVIDER=azure",
      "SPEL_EXTRARPMS=${local.amigen8_extra_rpms}",
      "SPEL_FIPSDISABLE=${var.amigen_fips_disable}",
      "SPEL_GRUBTMOUT=${var.amigen_grub_timeout}",
      "SPEL_HTTP_PROXY=${var.spel_http_proxy}",
      "SPEL_USEDEFAULTREPOS=${var.amigen_use_default_repos}",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    only = [
      "azure-arm.minimal-rhel-8-image",
    ]
    scripts = [
      "${path.root}/scripts/amigen8-build.sh",
    ]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E bash -ex '{{ .Path }}'"
    inline = [
      "chkconfig waagent on",
      "/usr/sbin/waagent -force -deprovision",
      "export HISTSIZE=0",
      "sync",
    ]
    only = [
      "azure-arm.minimal-rhel-8-image",
    ]
    skip_clean = true
  }

  # Common post-processors
  provisioner "file" {
    destination = ".spel/${var.spel_version}/${var.spel_identifier}-${source.name}.${source.type}.manifest.txt"
    direction   = "download"
    source      = "/tmp/manifest.txt"
  }

  post-processor "artifice" {
    files = [
      ".spel/${var.spel_version}/${var.spel_identifier}-${source.name}.${source.type}.manifest.txt",
    ]
  }

  post-processor "manifest" {
    output = ".spel/${var.spel_version}/packer-manifest.json"
  }
}

# Virtualbox builds
build {
  source "virtualbox-iso.base" {
    boot_command = ["<esc><wait>", "linux ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.centos9stream.minimal.cfg VAGRANT", "<enter><wait>"]
    name         = "minimal-centos-9stream"
    iso_checksum = "file:http://mirror.facebook.net/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso.SHA256SUM"
    iso_url      = var.virtualbox_iso_url_centos9stream
  }

  provisioner "file" {
    destination = "/tmp/retry.sh"
    source      = "${path.root}/scripts/retry.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant'|sudo -S -E /bin/bash -ex '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/base.sh",
      "${path.root}/scripts/virtualbox.sh",
      "${path.root}/scripts/vmware.sh",
      "${path.root}/scripts/vagrant.sh",
      "${path.root}/scripts/dep.sh",
      "${path.root}/scripts/cleanup.sh",
      "${path.root}/scripts/zerodisk.sh",
    ]
  }

  provisioner "file" {
    destination = ".spel/${var.spel_version}/${var.spel_identifier}-${source.name}.vagrant.manifest.txt"
    direction   = "download"
    source      = "/tmp/manifest.txt"
  }

  post-processor "artifice" {
    files = [
      ".spel/${var.spel_version}/${var.spel_identifier}-${source.name}.vagrant.manifest.txt",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level   = 9
      keep_input_artifact = false
      output              = ".spel/${var.spel_version}/${var.spel_identifier}-${source.name}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag             = "${var.virtualbox_vagrantcloud_username}/${var.spel_identifier}-${source.name}"
      keep_input_artifact = false
      version             = " ${var.spel_version} "
      # Lookup the description template values using source.name
      version_description = format(
        local.description,
        {
          "minimal-centos-9stream" = "CentOS Stream 9 image"
        }[source.name]
      )
    }
  }

  post-processor "manifest" {
    output = ".spel/${var.spel_version}/packer-manifest.json"
  }
}

###
# End of build blocks
###
