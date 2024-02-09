variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_source_ami_centos7_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_centos_7_hvm")
}

variable "aws_source_ami_centos8stream_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_centos_8stream_hvm")
}

variable "aws_source_ami_ol_8_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_ol_8_hvm")
}

variable "aws_source_ami_rhel7_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_rhel_7_hvm")
}

variable "aws_source_ami_rhel8_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_rhel_8_hvm")
}

variable "aws_source_ami_rhel9_hvm" {
  type    = string
  default = env("amazon_ebs_minimal_rhel_9_hvm")
}

variable "aws_ssh_interface" {
  type    = string
  default = "public_dns"
}

variable "aws_subnet_id" {
  type    = string
  default = ""
}

variable "aws_temporary_security_group_source_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
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

variable "spel_pypi_url" {
  type    = string
  default = "https://pypi.org/simple"
}

variable "spel_version" {
  type    = string
  default = env("SPEL_VERSION")
}

source "amazon-ebs" "base" {
  ami_description             = "This is a validation AMI for ${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp3"
  ami_name                    = "validation-${var.spel_identifier}-${source.name}-${var.spel_version}.x86_64-gp3"
  associate_public_ip_address = true
  communicator                = "ssh"
  ena_support                 = true
  force_deregister            = true
  instance_type               = "t3.large"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 21
    volume_type           = "gp3"
  }
  max_retries                           = 20
  region                                = var.aws_region
  skip_create_ami                       = true
  skip_save_build_region                = true
  sriov_support                         = true
  ssh_interface                         = var.aws_ssh_interface
  ssh_port                              = 22
  ssh_pty                               = true
  ssh_username                          = "spel"
  subnet_id                             = var.aws_subnet_id
  tags                                  = { Name = "" } # Empty name tag avoids inheriting "Packer Builder"
  temporary_security_group_source_cidrs = var.aws_temporary_security_group_source_cidrs
  user_data_file                        = "${path.root}/userdata/validation.cloud"
}

build {
  source "amazon-ebs.base" {
    source_ami = var.aws_source_ami_centos7_hvm
    name       = "minimal-centos-7-hvm"
  }

  source "amazon-ebs.base" {
    source_ami = var.aws_source_ami_centos8stream_hvm
    name       = "minimal-centos-8stream-hvm"
  }

  source "amazon-ebs.base" {
    source_ami = var.aws_source_ami_ol_8_hvm
    name       = "minimal-ol-8-hvm"
  }

  source "amazon-ebs.base" {
    source_ami = var.aws_source_ami_rhel7_hvm
    name       = "minimal-rhel-7-hvm"
  }

  source "amazon-ebs.base" {
    source_ami = var.aws_source_ami_rhel8_hvm
    name       = "minimal-rhel-8-hvm"
  }

  source "amazon-ebs.base" {
    source_ami = var.aws_source_ami_rhel9_hvm
    name       = "minimal-rhel-9-hvm"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E /bin/bash -ex -o pipefail '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/grow_check.sh",
    ]
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline = [
      "mkdir -p /tmp/spel/tests",
      "chown -R spel:spel /tmp/spel",
    ]
    pause_before = "5s"
  }

  provisioner "file" {
    destination  = "/tmp/spel/tests"
    direction    = "upload"
    pause_before = "5s"
    source       = "tests/"
  }

  provisioner "shell" {
    environment_vars = [
      "PYPI_URL=${var.spel_pypi_url}",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline = [
      "PYPI_URL=$${PYPI_URL:-https://pypi.org/simple}",
      "ls -alR /tmp",
      "python3 -m ensurepip",
      "python3 -m pip install --index-url=\"$PYPI_URL\" --upgrade pip setuptools",
      "python3 -m pip install --index-url=\"$PYPI_URL\" -r /tmp/spel/tests/requirements.txt",
      "for DEV in $(lsblk -ln | awk '/ part /{ print $1}'); do pvresize /dev/$${DEV} || true; done",
    ]
    pause_before = "5s"
  }

  provisioner "shell" {
    environment_vars = [
      "LVM_SUPPRESS_FD_WARNINGS=1",
      "SPEL_AMIUTILSOURCE=${var.spel_amiutilsource}",
      "SPEL_DISABLEFIPS=${var.spel_disablefips}",
    ]
    execute_command = "{{ .Vars }} sudo -E /bin/sh -ex -o pipefail '{{ .Path }}'"
    inline = [
      "PATH=/usr/local/bin:\"$PATH\"",
      "export PATH",
      "pytest --strict-markers -s -v --color=no /tmp/spel | tee /tmp/pytest.log",
    ]
    pause_before = "5s"
  }

  provisioner "file" {
    destination = ".spel/${var.spel_version}/validation-${var.spel_identifier}-${source.name}.log"
    direction   = "download"
    source      = "/tmp/pytest.log"
  }

  post-processor "artifice" {
    files = [
      ".spel/${var.spel_version}/validation-${var.spel_identifier}-${source.name}.log",
    ]
  }
}
