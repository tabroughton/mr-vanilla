resource "aws_ecr_repository" "ops_ecr" {
  name                 = "${var.ECR}"
  image_tag_mutability = "MUTABLE"
}
