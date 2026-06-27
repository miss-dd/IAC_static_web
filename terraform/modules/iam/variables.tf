variable "github_username" {
  description = "Your GitHub username"
  type        = string
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
}

variable "bucket_name" {
  description = "Website S3 bucket name"
  type        = string
}

variable "tfstate_bucket_name" {
  description = "Terraform state S3 bucket name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
