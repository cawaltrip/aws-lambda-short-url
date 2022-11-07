output "s3_backend_bucket" {
    value = aws_s3_bucket.backend.bucket
    description = "S3 backend bucket"
}

output "s3_backend_region" {
    value = aws_s3_bucket.backend.region
    description = "S3 backend region"
}

output "s3_backend_key" {
    value = var.backend_bucket_key
    description = "S3 backend key"
}