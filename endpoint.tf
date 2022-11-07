data "aws_route53_zone" "short_url_domain" {
  name = var.site_domain
}

resource "aws_route53_record" "short_url_domain_alias" {
  zone_id = data.aws_route53_zone.short_url_domain.zone_id
  name    = var.site_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.short_urls_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.short_urls_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "github_pages_verification" {
  zone_id = data.aws_route53_zone.short_url_domain.zone_id
  name = "_github-pages-challenge-cawaltrip.skelli.es"
  type = "TXT"
  ttl = 300

  records = [
    "ce0d38db47ad432df1a0b5bbd57d7c"
  ]
}

resource "aws_route53_record" "the_gregiverse_page" {
  zone_id = data.aws_route53_zone.short_url_domain.zone_id
  name = "gregiverse.${var.site_domain}"
  type = "CNAME"
  ttl = 300

  records = [
    "cawaltrip.github.io"
  ]
}

resource "aws_cloudfront_distribution" "short_urls_cloudfront" {
  depends_on = [aws_lambda_function.apply_security_headers]
  provider   = aws.cloudfront_acm
  enabled    = true
  aliases    = [var.site_domain]
  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.short_urls_bucket.id}"
    domain_name = aws_s3_bucket_website_configuration.short_urls_bucket.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    origin_id   = "origin-api-${aws_api_gateway_deployment.short_url_api_deployment.id}"
    domain_name = replace(replace(aws_api_gateway_deployment.short_url_api_deployment.invoke_url, "/Production", ""), "https://", "")
    origin_path = "/Production"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.short_urls_bucket.id}"

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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.short_url_domain_cert.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.1_2016"
  }
  logging_config {
    include_cookies = false
    bucket          = "skellies-terraform.s3.amazonaws.com"
    prefix          = "cloudfront-logging"
  }
  tags = {
    Project = "short_urls"
  }
}
