resource "aws_s3_bucket" "lambda_deployment_bucket" {
  bucket = var.LAMBDA_DEPLOYMENT_BUCKET
}

resource "aws_s3_bucket_acl" "lambda_deployment_bucket_acl" {
  bucket = aws_s3_bucket.lambda_deployment_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_deployment_bucket_lifecycle" {
  bucket = aws_s3_bucket.lambda_deployment_bucket.id

  rule {
    id     = "housekeeping"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}


data "aws_iam_policy_document" "lambda_deployment_bucket_policy_doc" {
  statement {
    principals {
      type        = "AWS"
      identifiers = var.envioronments_gha_oidc_role_arns
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.lambda_deployment_bucket.arn,
      "${aws_s3_bucket.lambda_deployment_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "lambda_deployment_bucket_policy" {
  bucket = aws_s3_bucket.lambda_deployment_bucket.id
  policy = data.aws_iam_policy_document.lambda_deployment_bucket_policy_doc.json
}

