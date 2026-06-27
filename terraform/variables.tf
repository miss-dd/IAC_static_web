variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "S3 bucket name for the website (must be globally unique)"
  type        = string
}

variable "restaurant_name" {
  description = "Name of the restaurant"
  type        = string
  default     = "La Bella Cucina"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "github_username" {
  description = "Your GitHub username"
  type        = string
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
  default     = "iac_static_web"
}

variable "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
}
