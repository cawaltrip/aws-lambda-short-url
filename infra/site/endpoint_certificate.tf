# SSL certificate for the domain.
resource "aws_acm_certificate" "domain_certificate" { # Was "short_url_domain_certificate"
  provider          = aws.cloudfront_acm
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags = {
    Project = var.project_tag
  }
}


resource "aws_acm_certificate_validation" "domain_cert" { # Was "short_url_domain_cert"
  provider                = aws.cloudfront_acm
  certificate_arn         = aws_acm_certificate.domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_cert_validation : record.fqdn]
}

resource "aws_route53_record" "domain_cert_validation" { # Was "short_url_domain_cert_validation"
  for_each = {
    for dvo in aws_acm_certificate.domain_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.id
}