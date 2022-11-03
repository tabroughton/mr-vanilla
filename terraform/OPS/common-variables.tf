#aerstudios convention:  variables in uppercase are expected to be set by env vars
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

variable "TF_VAR_LAMBDA_DEPLOYMENT_BUCKET" {
  type        = string
  description = "The location where lambda packages are stored for deploying"
}

variable "TF_VAR_LAMBDA_EDGE_DEPLOYMENT_BUCKET" {
  type        = string
  description = "The location where lambda@edge packages are stored for deploying"
}

variable "TF_VAR_UI_DEPLOYMENT_BUCKET" {
  type        = string
  description = "The location where UI files/artefacts are stored for deploying"
}
