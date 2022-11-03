resource "aws_s3_bucket" "lambda_edge_deployment_bucket" {
  bucket   = var.lambda_edge_deployment_bucket
  provider = aws.us-east-1
}

resource "aws_s3_bucket_acl" "lambda_edge_deployment_bucket_acl" {
  bucket   = aws_s3_bucket.lambda_edge_deployment_bucket.id
  acl      = "private"
  provider = aws.us-east-1
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_edge_deployment_bucket_lifecycle" {
  bucket = aws_s3_bucket.lambda_edge_deployment_bucket.id

  rule {
    id     = "housekeeping"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
  provider = aws.us-east-1
}

data "aws_iam_policy_document" "lambda_edge_deployment_bucket_policy_doc" {
  statement {
    principals {
      type        = "AWS"
      identifiers = var.environments_gha_oidc_role_arns
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.lambda_edge_deployment_bucket.arn,
      "${aws_s3_bucket.lambda_edge_deployment_bucket.arn}/*",
    ]
  }
}


resource "aws_s3_bucket_policy" "lambda_edge_deployment_bucket_policy" {
  bucket   = aws_s3_bucket.lambda_edge_deployment_bucket.id
  policy   = data.aws_iam_policy_document.lambda_edge_deployment_bucket_policy_doc.json
  provider = aws.us-east-1
}
