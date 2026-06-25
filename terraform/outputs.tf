# After running terraform apply, these values are printed to your terminal

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.bucket
}


output "cloudfront_url" {
  description = "Your live website URL (HTTPS via CloudFront)"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (needed for cache invalidation in Week 3)"
  value       = aws_cloudfront_distribution.website.id
}

output "s3_website_url" {
  description = "Direct S3 URL (HTTP only, now private — use cloudfront_url instead)"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

