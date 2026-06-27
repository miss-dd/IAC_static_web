variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
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

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}
