variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
  default     = "my-restaurant-website-fragrance-1"
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
  description = "CloudFront price class (PriceClass_100 = cheapest, US/EU only)"
  type        = string
  default     = "PriceClass_100"
}
