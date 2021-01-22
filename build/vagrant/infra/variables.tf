variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "a1.metal"
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

variable "packer_url" {
  type = string
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

variable "iso_url_centos7" {
  type = string
}
