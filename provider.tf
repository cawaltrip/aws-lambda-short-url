provider "aws" {
  region = var.region
  profile = var.profile_name
}
provider "aws" {
  region = "us-east-1"
  profile = var.profile_name
  alias  = "cloudfront_acm"
}
provider "archive" {
}

data "aws_caller_identity" "current" {
}