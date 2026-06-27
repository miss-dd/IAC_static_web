# -----------------------------------------------------------
# Root module — wires together all child modules
# -----------------------------------------------------------

# ── CloudFront (created first so we have its ARN for S3 policy) ──
module "cloudfront" {
  source = "./modules/cloudfront"

  bucket_name                 = var.bucket_name
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  restaurant_name             = var.restaurant_name
  environment                 = var.environment
  price_class                 = var.cloudfront_price_class
}

# ── S3 (depends on CloudFront ARN for bucket policy) ──
module "s3" {
  source = "./modules/s3"

  bucket_name                 = var.bucket_name
  restaurant_name             = var.restaurant_name
  environment                 = var.environment
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}

# ── IAM OIDC Role for GitHub Actions ──
module "iam" {
  source = "./modules/iam"

  github_username     = var.github_username
  github_repo         = var.github_repo
  bucket_name         = var.bucket_name
  tfstate_bucket_name = var.tfstate_bucket_name
  aws_region          = var.aws_region
}
