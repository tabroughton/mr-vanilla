variable "VERSION" {
  type = string
  description = "The terrafrom version"
}

variable "AWS_VERSION" {
  type = string
  description = "The version of the AWS provider"
}

variable "project_name" {
  type        = string
  description = "The name for the project"
}

variable "default_region" {
  type        = string
  description = "The default region for resource"
}

variable "environment" {
  type        = string
  description = "The aws environment eg int"
}
