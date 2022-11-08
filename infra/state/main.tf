resource "aws_s3_bucket" "backend" {
    bucket = var.backend_bucket
}

resource "aws_s3_bucket_versioning" "backend" {
    bucket = aws_s3_bucket.backend.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
    bucket = aws_s3_bucket.backend.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id
  
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "backend" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.allow_iam_user_access.json
}

resource "aws_s3_bucket_ownership_controls" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "allow_iam_user_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["${var.iam_user_arn}"]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = ["${var.backend_bucket_arn}"]
  }
  statement {
    principals {
      type = "AWS"
      identifiers = ["${var.iam_user_arn}"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${var.backend_bucket_arn}/*"]
  }
}