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
      "name"  = "PACKER_ZIP"
      "value" = "${var.packer_zip}"
    },
  ]
}

module "amis" {
  source    = "../../modules/amis"
  partition = "aws"
}

module "codebuild" {
  source = "../../modules/"

  project_name          = "spel"
  build_target_env      = "commercial-rc"
  ssm_key_name          = "${var.ssm_key_name}"
  project_description   = "Builds \"spel\" Release Candidate (RC) AMIs for AWS Commercial Regions"
  environment_variables = "${local.environment_variables}"
  target_ami_list       = "${module.amis.ids}"
}
