data "aws_route53_zone" "domain" { # Was "short_url_domain"
  name = var.domain_name
}

locals {
    s3_origin_id = "origin-bucket-${aws_s3_bucket.site_bucket.id}"
    api_origin_id = "origin-api-${aws_api_gateway_deployment.short_url_api_deployment.id}"
}

# Create a Route 53 hosted zone
# A Record that points to CloudFront distribution
resource "aws_route53_record" "domain_alias" { # Was "short_url_domain_alias"
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.domain_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.domain_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

# TXT record that proves domain ownership to GitHub for GitHub Pages.
# NOTE (Chris): This can likely be removed later.  Won't be hosting GitHub Pages eventually.
resource "aws_route53_record" "github_pages_verification" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name = "_github-pages-challenge-cawaltrip.skelli.es"
  type = "TXT"
  ttl = 300

  records = [
    "ce0d38db47ad432df1a0b5bbd57d7c"
  ]
}

# CNAME record to point gregiverse subdomain to GitHub Pages.
# NOTE (Chris): This can likely be removed later.  Won't be hosting GitHub Pages eventually.
resource "aws_route53_record" "the_gregiverse_page" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name = "gregiverse.${var.domain_name}"
  type = "CNAME"
  ttl = 300

  records = [
    "cawaltrip.github.io"
  ]
}

# The CloudFront Distribution itself.
resource "aws_cloudfront_distribution" "domain_cloudfront" { # Was "short_urls_cloudfront"
  depends_on = [aws_lambda_function.apply_security_headers]
  provider   = aws.cloudfront_acm
  enabled    = true
  is_ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases    = [var.domain_name]
  default_root_object = "index.html"
  origin {
    # Specifies that content is stored in an S3 bucket.
    origin_id   = local.s3_origin_id
    domain_name = aws_s3_bucket_website_configuration.site_bucket.website_endpoint

    # Because this is hosted a static website (that's how the S3 bucket is configured),
    # use a custom origin policy (per AWS documentation).  There is a rule to force
    # http to https, so the protocol here is fine.
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Specifies that some traffic is destined to API Gateway.
  # TODO (Chris): Read up on this some more so I understand why we're using /Production.  This
  #               is a relic of the original repo this came from.  I don't think it's doing anything.
  origin {
    origin_id   = local.api_origin_id
    domain_name = replace(replace(aws_api_gateway_deployment.short_url_api_deployment.invoke_url, "/Production", ""), "https://", "")
    origin_path = "/Production"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # TODO (Chris): Read up on the cache behaviors more!
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.apply_security_headers.qualified_arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  ordered_cache_behavior {
    path_pattern     = "admin*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-api-${aws_api_gateway_deployment.short_url_api_deployment.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.apply_security_headers.qualified_arn
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  # No restrictions.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Pointer to the SSL cert.  See `endpoint_certificate.tf` for the cert management.
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.domain_cert.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  # Log to logging S3 bucket
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging.bucket_domain_name
    prefix          = "${var.domain_name}/cf"
  }

  # Tag!
  tags = {
    Project = var.project_tag
  }
}
