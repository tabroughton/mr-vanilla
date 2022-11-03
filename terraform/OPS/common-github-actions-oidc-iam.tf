resource "aws_iam_openid_connect_provider" "github_actions_oidc_role" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [var.github-actions-oidc-thumbprint]
}

data "aws_iam_policy_document" "github-actions-oidc-assume-role-policy-doc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions_oidc_role.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      #IMPORTANT! this condition ensures only the repo running the github actions can assume this role
      values = [
        "repo:${var.github_actions_repo_owner}/${var.github_actions_repo_name}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_oidc_role" {
  name = "${var.PROJECT_NAME}-github-actions-oidc-role-${var.ENVIRONMENT}"
  assume_role_policy = aws_iam_policy_document.github-actions-oidc-assume-role-policy-doc.json

  inline_policy {
    name = "${var.PROJECT_NAME}-github-actions-oidc-role-inline-policy-${var.ENVIRONMENT}"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action": [
            "*"
          ],
          "Resource": [
            "*"
          ],
          "Effect": "Allow"
        }
      ]
    })
  }
}
