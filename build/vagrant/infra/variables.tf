variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "c6g.metal"
}

variable "ssm_vagrantcloud_token" {
  type = string
}

variable "vagrantcloud_user" {
  type = string
}

variable "spel_identifier" {
  type = string
}

variable "spel_version" {
  type = string
}

variable "spel_ci" {
  type = string
}

variable "resource_name" {
  type    = string
  default = "spel-vagrant"
}

variable "source_cidr" {
  type = string
}

variable "packer_version" {
  type    = string
  default = "1.3.3"
}

variable "artifact_location" {
  type = string
}

variable "kms_key" {
  type = string
}

variable "source_commit" {
  type = string
}

variable "code_repo" {
  type    = string
  default = "https://github.com/plus3it/spel.git"
}
