provider "aws" {
  region = var.region
  profile = "skellies" # Could use `var.profile_name` here instead.
}
provider "aws" {
  region = "us-west-2"
  profile = var.profile_name
  alias  = "cloudfront_acm"
}
provider "archive" {
}

data "aws_caller_identity" "current" {
}