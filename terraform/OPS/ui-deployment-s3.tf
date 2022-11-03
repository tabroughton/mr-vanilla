resource "aws_s3_bucket" "ui_deployment_bucket" {
  bucket = var.ui_deployment_bucket
}

resource "aws_s3_bucket_acl" "ui_deployment_bucket_acl" {
  bucket = aws_s3_bucket.ui_deployment_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "ui_deployment_bucket_lifecycle" {
  bucket = aws_s3_bucket.ui_deployment_bucket.id

  rule {
    id     = "housekeeping"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}


data "aws_iam_policy_document" "ui_deployment_bucket_policy_doc" {

  statement {
    principals {
      type        = "AWS"
      identifiers = var.environments_gha_oidc_role_arns
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectTagging",
      "s3:GetObjectAttributes",
      "s3:GetObjectAcl",
      "s3:GetObjectLegalHold",
      "s3:GetObjectRetention",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAttributes",
    ]

    resources = [
      aws_s3_bucket.ui_deployment_bucket.arn,
      "${aws_s3_bucket.ui_deployment_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "ui_deployment_bucket_policy" {
  bucket = aws_s3_bucket.ui_deployment_bucket.id
  policy = data.aws_iam_policy_document.ui_deployment_bucket_policy_doc.json
}

