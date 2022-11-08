provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}
provider "aws" {
  region = "us-east-1"
  profile = var.aws_profile
  alias  = "cloudfront_acm"
}
provider "archive" {
}

provider "template" {
}

data "aws_caller_identity" "current" {
}