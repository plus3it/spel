# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "azure_build_resource_group_name" {
  type    = string
  default = ""
}

variable "azure_client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "azure_client_secret" {
  type    = string
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "azure_dest_resource_group" {
  type    = string
  default = ""
}

variable "azure_environment" {
  type    = string
  default = ""
}

variable "azure_execute_using_public_ip" {
  type    = string
  default = ""
}

variable "azure_location" {
  type    = string
  default = ""
}

variable "azure_source_image_offer" {
  type    = string
  default = "RHEL"
}

variable "azure_source_image_publisher" {
  type    = string
  default = ""
}

variable "azure_source_image_sku" {
  type    = string
  default = ""
}

variable "azure_subnet_name" {
  type    = string
  default = ""
}

variable "azure_subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "azure_virtual_network_name" {
  type    = string
  default = ""
}

variable "azure_virtual_network_resource_group_name" {
  type    = string
  default = ""
}

variable "azure_vm_size" {
  type    = string
  default = "Standard_DS5_v2"
}

variable "root_volume_size" {
  type    = string
  default = "20"
}

variable "spel_http_proxy" {
  type    = string
  default = ""
}

variable "spel_identifier" {
  type    = string
  default = ""
}

variable "spel_version" {
  type    = string
  default = ""
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "azure-arm" "builder-azure-image" {
  build_resource_group_name              = "${var.azure_build_resource_group_name}"
  client_id                              = "${var.azure_client_id}"
  client_secret                          = "${var.azure_client_secret}"
  cloud_environment_name                 = "${var.azure_environment}"
  communicator                           = "ssh"
  image_offer                            = "${var.azure_source_image_offer}"
  image_publisher                        = "${var.azure_source_image_publisher}"
  image_sku                              = "${var.azure_source_image_sku}"
  location                               = "${var.azure_location}"
  managed_image_name                     = "${var.spel_identifier}-${build.name}-${var.spel_version}"
  managed_image_resource_group_name      = "${var.azure_dest_resource_group}"
  os_disk_size_gb                        = "${var.root_volume_size}"
  os_type                                = "Linux"
  private_virtual_network_with_public_ip = "${var.azure_execute_using_public_ip}"
  subscription_id                        = "${var.azure_subscription_id}"
  use_azure_cli_auth                     = true
  virtual_network_name                   = "${var.azure_virtual_network_name}"
  virtual_network_resource_group_name    = "${var.azure_virtual_network_resource_group_name}"
  virtual_network_subnet_name            = "${var.azure_subnet_name}"
  vm_size                                = "${var.azure_vm_size}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.azure-arm.builder-azure-image"]

  provisioner "shell" {
    environment_vars = ["SPEL_HTTP_PROXY=${var.spel_http_proxy}"]
    execute_command  = "{{ .Vars }} sudo -E /bin/sh -ex '{{ .Path }}'"
    only             = ["builder-azure-image"]
    scripts          = ["${path.root}/scripts/builder-azure-image.sh"]
  }

}
