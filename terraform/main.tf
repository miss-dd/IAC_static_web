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

# Bucket policy: allow anyone to read objects (public website)
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  # depends_on ensures the public access block is removed before applying the policy
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}
