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
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "pypi_url" {
  type    = string
  default = "https://pypi.org/simple"
}

variable "security_group_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "source_ami_centos7_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_centos_7_hvm")
}

variable "source_ami_centos8stream_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_centos_8stream_hvm")
}

variable "source_ami_rhel7_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_rhel_7_hvm")
}

variable "source_ami_rhel8_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_rhel_8_hvm")
}

variable "spel_amiutilsource" {
  type    = string
  default = env("SPEL_AMIUTILSOURCE")
}

variable "spel_disablefips" {
  type    = string
  default = ""
}

variable "spel_identifier" {
  type    = string
  default = env("SPEL_IDENTIFIER")
}

variable "spel_version" {
  type    = string
  default = env("SPEL_VERSION")
}

variable "ssh_interface" {
  type    = string
  default = "public_dns"
}

variable "subnet_id" {
  type    = string
  default = ""
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "minimal-centos-7-hvm" {
  ami_description             = "This is a validation AMI for ${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  ami_name                    = "validation-${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  associate_public_ip_address = true
  communicator                = "ssh"
  force_deregister            = "true"
  instance_type               = "m4.large"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 21
    volume_type           = "gp2"
  }
  max_retries                           = 20
  region                                = var.aws_region
  skip_create_ami                       = "true"
  skip_save_build_region                = "true"
  source_ami                            = var.source_ami_centos7_hvm
  ssh_interface                         = var.ssh_interface
  ssh_pty                               = true
  ssh_timeout                           = "60m"
  ssh_username                          = "spel"
  subnet_id                             = var.subnet_id
  temporary_security_group_source_cidrs = var.security_group_cidrs
  user_data_file                        = "${path.root}/userdata/validation.cloud"
}

source "amazon-ebs" "minimal-centos-8stream-hvm" {
  ami_description             = "This is a validation AMI for ${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  ami_name                    = "validation-${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  associate_public_ip_address = true
  communicator                = "ssh"
  force_deregister            = "true"
  instance_type               = "m4.large"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 21
    volume_type           = "gp2"
  }
  max_retries                           = 20
  region                                = var.aws_region
  skip_create_ami                       = "true"
  skip_save_build_region                = "true"
  source_ami                            = var.source_ami_centos8stream_hvm
  ssh_interface                         = var.ssh_interface
  ssh_pty                               = true
  ssh_timeout                           = "60m"
  ssh_username                          = "spel"
  subnet_id                             = var.subnet_id
  temporary_security_group_source_cidrs = var.security_group_cidrs
  user_data_file                        = "${path.root}/userdata/validation.cloud"
}

source "amazon-ebs" "minimal-rhel-7-hvm" {
  ami_description             = "This is a validation AMI for ${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  ami_name                    = "validation-${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  associate_public_ip_address = true
  communicator                = "ssh"
  force_deregister            = "true"
  instance_type               = "m4.large"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 21
    volume_type           = "gp2"
  }
  max_retries                           = 20
  region                                = var.aws_region
  skip_create_ami                       = "true"
  skip_save_build_region                = "true"
  source_ami                            = var.source_ami_rhel7_hvm
  ssh_interface                         = var.ssh_interface
  ssh_pty                               = true
  ssh_timeout                           = "60m"
  ssh_username                          = "spel"
  subnet_id                             = var.subnet_id
  temporary_security_group_source_cidrs = var.security_group_cidrs
  user_data_file                        = "${path.root}/userdata/validation.cloud"
}

source "amazon-ebs" "minimal-rhel-8-hvm" {
  ami_description             = "This is a validation AMI for ${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  ami_name                    = "validation-${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp2"
  associate_public_ip_address = true
  communicator                = "ssh"
  force_deregister            = "true"
  instance_type               = "m4.large"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 21
    volume_type           = "gp2"
  }
  max_retries                           = 20
  region                                = var.aws_region
  skip_create_ami                       = "true"
  skip_save_build_region                = "true"
  source_ami                            = var.source_ami_rhel8_hvm
  ssh_interface                         = var.ssh_interface
  ssh_pty                               = true
  ssh_timeout                           = "60m"
  ssh_username                          = "spel"
  subnet_id                             = var.subnet_id
  temporary_security_group_source_cidrs = var.security_group_cidrs
  user_data_file                        = "${path.root}/userdata/validation.cloud"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.minimal-centos-7-hvm", "source.amazon-ebs.minimal-centos-8stream-hvm", "source.amazon-ebs.minimal-rhel-7-hvm", "source.amazon-ebs.minimal-rhel-8-hvm"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline          = ["growpart /dev/xvda 2", "partprobe"]
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline          = ["mkdir -p /tmp/spel/tests", "chown -R spel:spel /tmp/spel"]
    pause_before    = "5s"
  }

  provisioner "file" {
    destination  = "/tmp/spel/tests"
    direction    = "upload"
    pause_before = "5s"
    source       = "tests/"
  }

  provisioner "shell" {
    environment_vars = ["PYPI_URL=${var.pypi_url}"]
    execute_command  = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline           = ["PYPI_URL=$${PYPI_URL:-https://pypi.org/simple}", "ls -alR /tmp", "python3 -m ensurepip", "python3 -m pip install --index-url=\"$PYPI_URL\" --upgrade pip setuptools", "python3 -m pip install --index-url=\"$PYPI_URL\" -r /tmp/spel/tests/requirements.txt", "for DEV in $(lsblk -ln | awk '/ part /{ print $1}'); do pvresize /dev/$${DEV} || true; done"]
    pause_before     = "5s"
  }

  provisioner "shell" {
    environment_vars = ["LVM_SUPPRESS_FD_WARNINGS=1", "SPEL_AMIUTILSOURCE=${var.spel_amiutilsource}", "SPEL_DISABLEFIPS=${var.spel_disablefips}"]
    execute_command  = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline           = ["PATH=/usr/local/bin:\"$PATH\"", "export PATH", "pytest --strict-markers -s -v --color=no /tmp/spel | tee /tmp/pytest.log"]
    pause_before     = "5s"
  }

  provisioner "file" {
    destination = ".spel/${var.spel_version}/validation-${var.spel_identifier}-${source.name}.log"
    direction   = "download"
    source      = "/tmp/pytest.log"
  }

  post-processor "artifice" {
    files = [".spel/${var.spel_version}/validation-${var.spel_identifier}-${source.name}.log"]
  }
}
