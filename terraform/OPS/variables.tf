variable "environments_gha_oidc_role_arns" {
  type        = list(string)
  description = "The environments managed by this account"
  default = [
    "arn:aws:iam::123213212312:role/github-actions-oidc-role",
    "arn:aws:iam::234232342323:role/github-actions-oidc-role",
    "arn:aws:iam::456345234123:role/github-actions-oidc-role"
  ]
}
