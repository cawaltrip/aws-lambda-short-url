resource "aws_iam_role" "short_url_lambda_iam" {
  name               = "short_url_lambda_iam"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "short_url_lambda_policy" {
  name = "short_url_lambda_policy"
  role = aws_iam_role.short_url_lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stm1",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Sid": "Stm2",
      "Effect": "Allow",
      "Action": [
        "lambda:GetFunction"
      ],
      "Resource": "${aws_lambda_function.apply_security_headers.arn}:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "short_url_s3_policy" {
  name        = "short_url_s3_policy"
  description = "Short URL S3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.domain_name}/",
        "arn:aws:s3:::${var.domain_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "short_url_lambda_policy_s3_policy_attachment" {
  role       = aws_iam_role.short_url_lambda_iam.name
  policy_arn = aws_iam_policy.short_url_s3_policy.arn
}

# IAM user for publishing static site
resource "aws_iam_user" "publish" {
  name = var.iam_publish_user

  # This part isn't strictly necessary, but it helps in the ordering
  # that happens when running apply.
  depends_on = [
    aws_cloudfront_distribution.domain_cloudfront
  ]
}

resource "aws_iam_access_key" "publish" {
  user = aws_iam_user.publish.name
}

# Policy for this user
data "template_file" "publish-policy" {
  template = "${file("./templates/publish_user_policy.json")}"
  vars = {
    bucket = aws_s3_bucket.site_bucket.arn
    distribution = aws_cloudfront_distribution.domain_cloudfront.arn
  }
}