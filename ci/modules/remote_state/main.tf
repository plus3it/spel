provider "aws" {}

data "aws_region" "current" {}

module "terraform_state_backend" {
  source     = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.project_name}"
  attributes = ["state"]
  region     = "${data.aws_region.current.name}"
}
