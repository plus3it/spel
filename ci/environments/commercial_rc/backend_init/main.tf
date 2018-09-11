provider "aws" {}

variable "project_name" {}
variable "stage" {}

module "terraform_state_backend" {
  source       = "../../../modules/remote_state"
  namespace    = "spel"
  stage        = "${var.stage}"
  project_name = "${replace(var.project_name, "_", "-")}"
}

output "s3_bucket_id" {
  value = "${module.terraform_state_backend.s3_bucket_id}"
}

output "dynamodb_table_name" {
  value = "${module.terraform_state_backend.dynamodb_table_name}"
}
