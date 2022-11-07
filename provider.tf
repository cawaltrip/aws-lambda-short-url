provider "aws" {
  region = var.aws_region
  profile = var.aws_profile_name
}
provider "aws" {
  region = "us-east-1"
  profile = var.aws_profile_name
  alias  = "cloudfront_acm"
}
provider "archive" {
}

data "aws_caller_identity" "current" {
}