variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS reegion to use for the Short URL project."
}
variable "aws_profile" {
  type = string
  description = "The AWS profile name to use from credentials file."
}
variable "domain_name" {
  type        = string
  description = "The domain name to use for short URLs."
}
variable "default_redirect_hostname" {
  type = string
  description = "Hostname to redirect to if an object doesn't exist."
}
variable "default_redirection_subdirectory" {
  type = string
  description = "Subdirectory to attach to hostname for redirection when an object doesn't exist."
}
variable "iam_publish_user" {
  type = string
  description = "Name of the IAM user that will publish static website."
}
variable "project_tag" {
  type = string
  description = "Tag that's used on resources."
  default = "short_urls"
}