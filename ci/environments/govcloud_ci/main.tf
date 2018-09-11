provider "aws" {
  alias = "commercial"
}

terraform {
  backend "s3" {}
}

provider "aws" {
  alias      = "govcloud"
  region     = "${var.govcloud_region}"
  access_key = "${var.govcloud_access_key}"
  secret_key = "${var.govcloud_secret_key}"
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
      "name"  = "SPEL_SSM_ACCESS_KEY"
      "value" = "${var.spel_ssm_access_key}"
    },
    {
      "name"  = "SPEL_SSM_SECRET_KEY"
      "value" = "${var.spel_ssm_secret_key}"
    },
    {
      "name"  = "SPEL_CI"
      "value" = "${var.spel_ci}"
    },
    {
      "name"  = "SPEL_PIN_AWSCLI_BUNDLE"
      "value" = "${var.spel_pin_awscli_bundle}"
    },
  ]
}

module "amis" {
  source    = "../../modules/amis"
  partition = "aws-us-gov"

  providers = {
    aws = "aws.govcloud"
  }
}

module "codebuild" {
  source = "../../modules/"

  providers = {
    aws = "aws.commercial"
  }

  project_name          = "spel"
  build_target_env      = "govcloud-ci"
  ssm_key_name          = "${var.ssm_key_name}"
  project_description   = "Executes Continuous Integration tests for spel in the GovCloud region"
  target_ami_list       = "${module.amis.ids}"
  environment_variables = "${local.environment_variables}"
}
