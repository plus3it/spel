provider "aws" {}

// bucket: spel-cicd-testing
locals {
  full_project_name     = "${var.project_name}-${var.build_target_env}-test"
  artifacts_bucket_name = "${local.full_project_name}-codebuild-artifacts"
}

//configure the S3 buckets for codebuild logging and terraform artifacts

resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = "${local.artifacts_bucket_name}"
  acl    = "private"
}

//Import the iam module
//Creates project specific roles
module "iam" {
  source       = "iam"
  ssm_key_name = "${var.ssm_key_name}"
  project_name = "${local.full_project_name}"
}

//Create the codebuild project
resource "aws_codebuild_project" "example" {
  name          = "${local.full_project_name}"
  description   = "${var.project_description}"
  build_timeout = "75"
  service_role  = "${module.iam.role_arn}"

  artifacts {
    type     = "S3"
    location = "${local.artifacts_bucket_name}"
    name     = "${local.full_project_name}"

    //  path     = "${var.build_target_env}/artifacts"
    path = "/"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/ubuntu-base:14.04"
    type         = "LINUX_CONTAINER"

    environment_variable = ["${var.environment_variables}", "${var.target_ami_list}"]
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/plus3it/spel"
    git_clone_depth = 0
  }

  tags {
    "Environment" = "${var.build_target_env}"
  }
}
