#Whenever a new env is created with a new oidc role, the role needs to be added here and ops tf needs to be applied
variable "environments_gha_oidc_role_arns" {
  type        = list(string)
  description = "The environments that need to access the deployment resources"
  default = [
    "arn:aws:iam::123213212312:role/github-actions-oidc-role",
    "arn:aws:iam::234232342323:role/github-actions-oidc-role",
    "arn:aws:iam::456345234123:role/github-actions-oidc-role"
  ]
}
