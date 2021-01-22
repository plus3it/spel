### Locals ###
locals {
  project_tags = {
    Project = "spel-vagrant"
    Name    = var.resource_name
  }
}

### Resources ###
# Create IAM Role
resource "aws_iam_role" "ec2_s3_access_role" {
  name = var.resource_name
  tags = local.project_tags

  assume_role_policy = templatefile(
    "${path.module}/policy/ec2_s3_access_role.json",
    {}
  )
}

# Create IAM Policy
resource "aws_iam_policy" "s3_upload_policy" {
  name = var.resource_name

  policy = templatefile(
    "${path.module}/policy/s3_upload_policy.json",
    {
      artifact_location      = var.artifact_location
      ssm_vagrantcloud_token = var.ssm_vagrantcloud_token
      kms_key                = var.kms_key
      region                 = data.aws_region.region.name
      account                = data.aws_caller_identity.account.account_id
    }
  )
}

# Attach Policy to IAM Role
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = var.resource_name
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = var.resource_name
  role = aws_iam_role.ec2_s3_access_role.name
}

# Generate SSH Key Pair
resource "tls_private_key" "gen_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Define key pair to be used for EC2 instance
resource "aws_key_pair" "auth" {
  key_name   = var.resource_name
  public_key = tls_private_key.gen_key.public_key_openssh
}

resource "aws_security_group" "security_group" {
  name        = var.resource_name
  description = "Only allow for the build job to access the instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.source_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.project_tags
}

# Create EC2 Instance
resource "aws_instance" "metal_instance" {
  ami                  = data.aws_ami.ubuntu.id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  instance_type        = var.instance_type
  key_name             = aws_key_pair.auth.key_name
  security_groups      = [aws_security_group.security_group.name]
  tags                 = local.project_tags

  provisioner "file" {
    destination = "/tmp/spel-vagrant.sh"

    content = templatefile(
      "${path.module}/spel-vagrant.sh",
      {
        artifact_location      = var.artifact_location
        code_repo              = var.code_repo
        iso_url_centos7        = var.iso_url_centos7
        packer_url             = var.packer_url
        source_commit          = var.source_commit
        spel_identifier        = var.spel_identifier
        spel_version           = var.spel_version
        spel_ci                = var.spel_ci
        ssm_vagrantcloud_token = var.ssm_vagrantcloud_token
        vagrantcloud_user      = var.vagrantcloud_user
      }
    )

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.gen_key.private_key_pem
      port        = "22"
      timeout     = "30m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "export AWS_REGION=${var.aws_region}",
      "export PACKER_NO_COLOR=true",
      "chmod +x /tmp/spel-vagrant.sh",
      "/tmp/spel-vagrant.sh ",
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.gen_key.private_key_pem
      port        = "22"
      timeout     = "30m"
    }
  }
}

### Data Sources ###
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

data "aws_caller_identity" "account" {}

data "aws_region" "region" {}
