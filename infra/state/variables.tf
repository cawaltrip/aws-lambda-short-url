variable "backend_bucket" {
    # If this changes, make sure to update `backend_bucket_arn` as well.
    type = string
    default = "skellies-backend"
}
variable "backend_bucket_arn" {
    type = string
    default = "arn:aws:s3:::skellies-backend"
}
variable "backend_bucket_key" {
    type = string
    default = "prod/terraform.tfstate"
}
variable "aws_profile" {
    type = string
    default = "skellies"
}
variable "aws_region" {
    type = string
    default = "us-west-2"
}
variable "skellies_arn" {
    type = string
    default = "arn:aws:iam::917360195955:user/skellies"
}
