#aerstudios convention:  variables in uppercase are expected to be set by env vars
variable "PROJECT_NAME" {
  type        = string
  description = "The name for the project"
  default     = ""
}

variable "DEFAULT_REGION" {
  type        = string
  description = "The default region for resource"
  default     = ""
}

variable "ENVIRONMENT" {
  type        = string
  description = "The aws environment eg int"
  default     = ""
}

variable "TF_VAR_LAMBDA_DEPLOYMENT_BUCKET" {
  type        = string
  description = "The location where lambda packages are stored for deploying"
  default     = ""
}

variable "TF_VAR_LAMBDA_EDGE_DEPLOYMENT_BUCKET" {
  type        = string
  description = "The location where lambda@edge packages are stored for deploying"
  default     = ""
}

variable "TF_VAR_UI_DEPLOYMENT_BUCKET" {
  type        = string
  description = "The location where UI files/artefacts are stored for deploying"
  default     = ""
}

variable "github_actions_oidc_thumbprint" {
  type        = string
  description = "the thumbprint used by github actions, this changes periodically (seems to be yearly) so if any issue with github actions access check this value is correct."
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "github_actions_repo_owner" {
  type        = string
  description = "the user/org/owner of the repo where github actions is running"
  default     = "tabroughton"
}

variable "github_actions_repo_name" {
  type        = string
  description = "The name of the repo where github actions is running"
  default     = "mr-vanilla"
}
