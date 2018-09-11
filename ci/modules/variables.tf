variable "project_name" {
  type        = "string"
  description = "The name of the project"
}

variable "build_target_env" {
  type        = "string"
  description = "What the codebuild project is tarteting ie: commercial_ci, govcloud_rc, etc."
}

variable "ssm_key_name" {
  type        = "string"
  description = "Alias of the target account's ssm key"
}

variable "project_description" {
  type        = "string"
  description = "codebuild project description"
}

variable "target_ami_list" {
  type        = "list"
  description = "List of maps containing the environment varabiles for the target amis"
}

variable "environment_variables" {
  type = "list"

  default     = []
  description = "list of maps containing additional environment variables for codebuild. Expects a \"name\" and \"value\" keypair"

  # Example:
  # environment_variables = [
  #   {
  #     "name"  = "TEST_VAR_1"
  #     "value" = "TRUE"
  #   },
  #   {
  #     "name"  = "TEST_VAR_2"
  #     "value" = "TRUE"
  #   },
  # ]
}
