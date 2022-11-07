terraform {
    backend "s3" {
        bucket = "skellies-terraform"
        key = "prod/terraform.tfstate"
        region = "us-west-2"
        profile = "skellies"
    }
}