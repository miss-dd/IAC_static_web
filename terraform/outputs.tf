# After running terraform apply, these values are printed to your terminal

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.bucket
}

output "website_url" {
  description = "Public URL of your restaurant website"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "bucket_arn" {
  description = "ARN of the S3 bucket (needed in Week 2 for CloudFront)"
  value       = aws_s3_bucket.website.arn
}
