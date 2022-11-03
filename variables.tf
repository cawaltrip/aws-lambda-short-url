variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS reegion to use for the Short URL project."
}
variable "short_url_domain" {
  type        = string
  default = "skelli.es"
  description = "The domain name to use for short URLs."
}
variable "profile_name" {
  type = string
  default = "skellies"
  description = "The AWS profile name to use from credentials file."
}