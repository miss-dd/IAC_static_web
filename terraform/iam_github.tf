# -----------------------------------------------------------
# IAM OIDC — lets GitHub Actions authenticate to AWS
# without storing any AWS access keys as secrets
# -----------------------------------------------------------

# Fetch your AWS account ID automatically
data "aws_caller_identity" "current" {}

# GitHub's OIDC provider (tells AWS to trust GitHub's tokens)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint (stable — does not need to change)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# IAM Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions" {
  name = "github-actions-restaurant-website"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # IMPORTANT: Replace with your GitHub username and repo name
            "token.actions.githubusercontent.com:sub" = "repo:miss-dd/IAC_static_web:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
  }
}

# Policy: what GitHub Actions is allowed to do
resource "aws_iam_role_policy" "github_actions" {
  name = "github-actions-restaurant-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3: manage the website bucket + state bucket
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "s3:CreateBucket",
            "s3:PutBucketWebsite",
            "s3:PutPublicAccessBlock",
            "s3:GetPublicAccessBlock",
            "s3:GetBucketAcl",
            "s3:PutBucketAcl",
            "s3:GetBucketWebsite",
            "s3:GetEncryptionConfiguration",
            "s3:GetBucketObjectLockConfiguration",
            "s3:GetBucketVersioning",
            "s3:GetBucketRequestPayment",
            "s3:GetBucketLogging",
            "s3:GetLifecycleConfiguration",
            "s3:GetReplicationConfiguration",
            "s3:GetBucketTagging"
]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::website-tfstate-la-bella-cucina-fragrance-1",       # <-- change this
          "arn:aws:s3:::website-tfstate-la-bella-cucina-fragrance-1/*"      # <-- change this
        ]
      },
      # DynamoDB: Terraform state locking
      {
        Sid    = "DynamoDBLock"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/terraform-lock"
      },
      # CloudFront: manage distribution + invalidations
      {
        Sid    = "CloudFrontAccess"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:DeleteDistribution",
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:DeleteOriginAccessControl",
          "cloudfront:ListDistributions",
          "cloudfront:TagResource"
        ]
        Resource = "*"
      },
      # IAM: read-only (Terraform needs to check existing roles)
      {
        Sid    = "IAMReadOnly"
        Effect = "Allow"
        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

# Output the role ARN — you'll add this as a GitHub secret
output "github_actions_role_arn" {
  description = "Add this as AWS_ROLE_ARN in your GitHub repository secrets"
  value       = aws_iam_role.github_actions.arn
}
