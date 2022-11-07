variable "backend_bucket" {
    default = "skellies-backend"
}
variable "backend_bucket_key" {
    default = "prod/terraform.tfstate"
}
variable "aws_profile" {
    default = "skellies"
}
variable "aws_region" {
    default = "us-west-2"
}