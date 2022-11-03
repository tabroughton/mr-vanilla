resource "aws_ecr_repository" "container_deployment_ecr" {
  name                 = var.ECR
  image_tag_mutability = "MUTABLE"
}


resource "aws_ecr_repository_policy" "container_deployment_ecr_policy" {
  repository = aws_ecr_repository.contianer_deployment_ecr

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "allow-env-deploy-from-ecr",
        Effect = "Allow",
        Principal = {
          AWS = [ var.var.environments_gha_oidc_role_arns]
        },
        Action = [
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages"
        ]
      }
    ]  
  })
}
