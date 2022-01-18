variable "aws_instance_type" {
  type    = string
  default = "c5n.metal"
}

variable "aws_temporary_security_group_source_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "spel_ci" {
  type    = bool
  default = false
}

variable "spel_identifier" {
  type = string
}

variable "spel_packer_url" {
  type = string
}

variable "spel_repo_commit" {
  type    = string
  default = "master"
}

variable "spel_repo_url" {
  type    = string
  default = "https://github.com/plus3it/spel.git"
}

variable "spel_version" {
  type = string
}

variable "vagrant_cloud_token" {
  type    = string
  default = env("VAGRANT_CLOUD_TOKEN")
}

variable "vagrant_cloud_user" {
  type    = string
  default = "plus3it"
}

variable "virtualbox_iso_url_centos7" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  ami_name                    = "builder-${var.spel_identifier}-vagrant-${var.spel_version}.x86_64-gp2"
  associate_public_ip_address = true
  communicator                = "ssh"
  force_deregister            = true
  instance_type               = var.aws_instance_type
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp2"
  }
  max_retries            = 20
  skip_create_ami        = true
  skip_save_build_region = true
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  ssh_port                              = 22
  ssh_pty                               = true
  ssh_username                          = "ubuntu"
  temporary_security_group_source_cidrs = var.aws_temporary_security_group_source_cidrs
}

build {
  sources = ["amazon-ebs.ubuntu"]

  provisioner "shell" {
    environment_vars = [
      "PACKER_NO_COLOR=1",
      "SPEL_CI=${var.spel_ci}",
      "SPEL_IDENTIFIER=${var.spel_identifier}",
      "SPEL_PACKER_URL=${var.spel_packer_url}",
      "SPEL_REPO_COMMIT=${var.spel_repo_commit}",
      "SPEL_REPO_URL=${var.spel_repo_url}",
      "SPEL_VERSION=${var.spel_version}",
      "VAGRANT_CLOUD_TOKEN=${var.vagrant_cloud_token}",
      "VAGRANT_CLOUD_USER=${var.vagrant_cloud_user}",
      "VIRTUALBOX_ISO_URL_CENTOS7=${var.virtualbox_iso_url_centos7}",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
    scripts = [
      "${path.root}/build-spel-vagrant.sh",
    ]
  }

  provisioner "file" {
    destination = ".spel/"
    direction   = "download"
    source      = "/tmp/spel/.spel/${var.spel_version}/"
  }
}
