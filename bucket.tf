resource "aws_s3_bucket" "short_urls_bucket" {
  bucket = var.short_url_domain

  tags = {
    Project = "short_urls"
  }
}

resource "aws_s3_bucket_website_configuration" "short_urls_bucket" {
  bucket = aws_s3_bucket.short_urls_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
      condition {
        http_error_code_returned_equals = 404
      }
      redirect {
        host_name = var.default_redirect_hostname
        http_redirect_code = 302
        protocol = "https"
        replace_key_prefix_with = var.default_redirection_subdirectory
      }
    }
}

resource "aws_s3_bucket_acl" "short_urls_bucket" {
  bucket = aws_s3_bucket.short_urls_bucket.id
  acl = "public-read"
}
