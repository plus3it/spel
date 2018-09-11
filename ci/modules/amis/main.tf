variable "partition" {} # "aws" or "aws-us-gov"

locals {
  centos_ami_owners = {
    aws        = "701759196663"
    aws-us-gov = "039368651566"
  }

  rhel_ami_owners = {
    aws        = "309956199498"
    aws-us-gov = "219670896067"
  }
}

//rhel6 hvm - commercial
data "aws_ami" "rhel6_hvm_com" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["${local.rhel_ami_owners[var.partition]}"]
  }

  filter {
    name   = "name"
    values = ["RHEL-6.*_HVM*-x86_64-*-GP2"]
  }
}

//rhel7_hvm commercial
data "aws_ami" "rhel7_hvm_com" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["${local.rhel_ami_owners[var.partition]}"]
  }

  filter {
    name   = "name"
    values = ["RHEL-7.*_HVM*-x86_64-*-GP2"]
  }
}

//centos6_hvm commercial
data "aws_ami" "centos6_hvm_com" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["${local.centos_ami_owners[var.partition]}"]
  }

  filter {
    name   = "name"
    values = ["*Recovery*CentOS6-HVM"]
  }
}

//centos6_pvm commercial
data "aws_ami" "centos6_pvm_com" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["${local.centos_ami_owners[var.partition]}"]
  }

  filter {
    name   = "name"
    values = ["*Recovery*CentOS6-PVM"]
  }
}

//centos7_hvm commercial
data "aws_ami" "centos7_hvm_com" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["${local.centos_ami_owners[var.partition]}"]
  }

  filter {
    name   = "name"
    values = ["*Recovery*CentOS7-HVM*"]
  }
}

output "ids" {
  value = [
    {
      "name"  = "SOURCE_AMI_CENTOS6_HVM"
      "value" = "${data.aws_ami.centos6_hvm_com.id}"
    },
    {
      "name"  = "SOURCE_AMI_CENTOS6_PVM"
      "value" = "${data.aws_ami.centos6_pvm_com.id}"
    },
    {
      "name"  = "SOURCE_AMI_CENTOS7_HVM"
      "value" = "${data.aws_ami.centos7_hvm_com.id}"
    },
    {
      "name"  = "SOURCE_AMI_RHEL6_HVM"
      "value" = "${data.aws_ami.rhel6_hvm_com.id}"
    },
    {
      "name"  = "SOURCE_AMI_RHEL7_HVM"
      "value" = "${data.aws_ami.rhel7_hvm_com.id}"
    },
  ]
}
