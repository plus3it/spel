variable "stage" {
  type        = "string"
  default     = "test"
  description = "test|dev|prod"
}

variable "project_name" {
  type        = "string"
  description = "name of the project"
}

variable "namespace" {
  type = "string"
}
