output "bucket_name" {
  description = "Name of the S3 website bucket"
  value       = module.s3.bucket_name
}

output "cloudfront_url" {
  description = "Live website URL (HTTPS via CloudFront)"
  value       = "https://${module.cloudfront.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (CF_DISTRIBUTION_ID GitHub secret)"
  value       = module.cloudfront.distribution_id
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions (AWS_ROLE_ARN GitHub secret)"
  value       = module.iam.github_actions_role_arn
}