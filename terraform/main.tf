# -----------------------------------------------------------
# S3 Bucket for Static Website Hosting
# -----------------------------------------------------------

# Create the S3 bucket
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name        = var.restaurant_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Disable "Block All Public Access" so the bucket can serve a website
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enable static website hosting on the bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# -----------------------------------------------------------
# CloudFront Origin Access Control (OAC)
# Allows CloudFront to securely fetch objects from the private S3 bucket
# -----------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.restaurant_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------------------------------------------
# CloudFront Distribution
# -----------------------------------------------------------

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "${var.restaurant_name} website"
  price_class         = "PriceClass_100" # US, Canada, Europe only (cheapest)

  # Origin: the private S3 bucket
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  # Default cache behaviour
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https" # HTTP → HTTPS automatically

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # Cache files for 1 hour by default
    max_ttl     = 86400 # Max cache 24 hours
  }

  # Custom error response: show error.html for 404s
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # No geo-blocking — open to the world
    }
  }

  # HTTPS using CloudFront's default certificate (free)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = var.restaurant_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Must wait for S3 public access block before creating distribution
  depends_on = [aws_s3_bucket_public_access_block.website]
}

# -----------------------------------------------------------
# S3 Bucket Policy — allow ONLY CloudFront to read objects
# -----------------------------------------------------------

resource "aws_s3_bucket_policy" "website" {
  bucket     = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}
