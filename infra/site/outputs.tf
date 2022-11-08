output "short_url_domain" {
  value = var.domain_name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.domain_cloudfront.domain_name
}

output "admin_api_key" {
  value = aws_api_gateway_api_key.short_urls_admin_api_key.value
  sensitive = true
}
