resource "aws_ecr_repository" "container_repo_ecr" {
  name                 = var.ECR
  image_tag_mutability = "MUTABLE"
}
