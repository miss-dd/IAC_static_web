variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "restaurant_name" {
  description = "Name of the restaurant"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution allowed to read from this bucket"
  type        = string
}
