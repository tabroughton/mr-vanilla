output "github_actions_oidc_role_arn" {
  description = "The arn of the github actions oidc role"
  value       = aws_iam_role.github_actions_oidc_role.arn
}
