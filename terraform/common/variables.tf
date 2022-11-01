#aerstudios convention:  variables in uppercase are expected to be set by env vars
variable "VERSION" {
  type = string
  description = "The terrafrom version"
}

variable "AWS_VERSION" {
  type = string
  description = "The version of the AWS provider"
}

variable "PROJECT_NAME" {
  type        = string
  description = "The name for the project"
}

variable "DEFAULT_REGION" {
  type        = string
  description = "The default region for resource"
}

variable "ENVIRONMENT" {
  type        = string
  description = "The aws environment eg int"
}
