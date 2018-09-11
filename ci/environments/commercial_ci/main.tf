provider "aws" {}

terraform {
  backend "s3" {}
}

locals {
  environment_variables = [
    {
      "name"  = "AWS_REGION"
      "value" = "${var.commercial_aws_region}"
    },
    {
      "name"  = "SPEL_EXTRARPMS"
      "value" = "${var.spel_extrapms}"
    },
    {
      "name"  = "SPEL_IDENTIFIER"
      "value" = "${var.spel_identifier}"
    },
    {
      "name"  = "SPEL_BUILDERS"
      "value" = "${var.spel_builders}"
    },
    {
      "name"  = "SPEL_CI"
      "value" = "true"
    },
    {
      "name"  = "SPEL_PIN_AWSCLI_BUNDLE"
      "value" = "true"
    },
  ]
}

module "amis" {
  source    = "../../modules/amis"
  partition = "aws"
}

module "codebuild" {
  source = "../../modules"

  project_name          = "spel"
  build_target_env      = "commercial-ci"
  ssm_key_name          = "${var.ssm_key_name}"
  project_description   = "Executes Continuous Integration tests for spel in the Commercial regions"
  environment_variables = "${local.environment_variables}"
  target_ami_list       = "${module.amis.ids}"
}
