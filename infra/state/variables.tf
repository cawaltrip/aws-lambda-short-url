variable "backend_bucket" {
    # If this changes, make sure to update `backend_bucket_arn` as well.
    type = string
}
variable "backend_bucket_arn" {
    type = string
}
variable "backend_bucket_key" {
    type = string
}
variable "aws_profile" {
    type = string
}
variable "aws_region" {
    type = string
    default = "us-west-2"
}
variable "iam_user_arn" {
    type = string
}
