# Main site bucket
resource "aws_s3_bucket" "site_bucket" {
  bucket = var.domain_name

  tags = {
    Project = var.project_tag
  }
}

resource "aws_s3_bucket_website_configuration" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id

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
        #host_name = var.default_redirect_hostname
        host_name = var.domain_name
        http_redirect_code = 302
        protocol = "https"
        #replace_key_prefix_with = var.default_redirection_subdirectory
      }
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site_bucket" {
    bucket = aws_s3_bucket.site_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "site_bucket" {
    bucket = aws_s3_bucket.site_bucket.id
    policy = data.template_file.public_bucket_policy.rendered
}

resource "aws_s3_bucket_logging" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "${var.domain_name}/s3/root"
}

resource "aws_s3_bucket_acl" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id
  acl = "public-read"
}

data "template_file" "public_bucket_policy" {
    template = "${file("./templates/public_bucket_policy.json")}"
    vars = {
        bucket = aws_s3_bucket.site_bucket.id
    }
}

# WWW Redirect Bucket
resource "aws_s3_bucket" "www_site_bucket" {
    bucket = "www.${var.domain_name}"
}

resource "aws_s3_bucket_website_configuration" "www_site_bucket" {
    bucket = aws_s3_bucket.www_site_bucket.id
    redirect_all_requests_to {
      host_name = var.domain_name
    }
}

resource "aws_s3_bucket_logging" "www_site_bucket" {
  bucket = aws_s3_bucket.www_site_bucket.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "${var.domain_name}/s3/www"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "www_site_bucket" {
    bucket = aws_s3_bucket.www_site_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "www_site_bucket" {
    bucket = aws_s3_bucket.www_site_bucket.id
    policy = data.template_file.www_public_bucket_policy.rendered
}

resource "aws_s3_bucket_acl" "www_site_bucket" {
  bucket = aws_s3_bucket.www_site_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket_public_access_block" "www_site_bucket" {
    bucket = aws_s3_bucket.www_site_bucket.id
}

data "template_file" "www_public_bucket_policy" {
    template = "${file("./templates/public_bucket_policy.json")}"
    vars = {
        bucket = aws_s3_bucket.www_site_bucket.id
    }
}


# Logging bucket
resource "aws_s3_bucket" "logging" {
    bucket = "${var.domain_name}-logging"
}
resource "aws_s3_bucket_acl" "logging" {
    bucket = aws_s3_bucket.logging.id
    acl = "log-delivery-write"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
    bucket = aws_s3_bucket.logging.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}
resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.logging.id
  
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
