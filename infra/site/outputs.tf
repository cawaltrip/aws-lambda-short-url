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

output "cf_distribution_id" {
  value       = aws_cloudfront_distribution.domain_cloudfront.id
  description = "CloudFront distribution ID"
}

output "iam_publish_access_key" {
  value       = aws_iam_access_key.publish.id
  description = "Access Key ID for publish user"
}

output "iam_publish_secret_key" {
  value       = aws_iam_access_key.publish.secret
  description = "Secret access key for publish user"
  sensitive = true
}

output "s3_bucket_url" {
  value       = "s3://${aws_s3_bucket.site_bucket.id}?region=${aws_s3_bucket.site_bucket.region}"
  description = "S3 site bucket URL"
}

output "s3_redirect_endpoint" {
  value       = aws_s3_bucket_website_configuration.www_site_bucket.website_endpoint
  description = "S3 www redirect endpoint"
}
