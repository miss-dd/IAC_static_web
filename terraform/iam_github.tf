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
     # S3: full access on the website bucket + state bucket only
{
  Sid      = "S3Access"
  Effect   = "Allow"
  Action   = ["s3:*"]
  Resource = [
    "arn:aws:s3:::${var.bucket_name}",
    "arn:aws:s3:::${var.bucket_name}/*",
    "arn:aws:s3:::website-tfstate-la-bella-cucina-fragrance-1",
    "arn:aws:s3:::website-tfstate-la-bella-cucina-fragrance-1/*"
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
     # CloudFront: full access (scoped to this role only)
            {
            Sid      = "CloudFrontAccess"
            Effect   = "Allow"
            Action   = ["cloudfront:*"]
            Resource = "*"
            },
     # IAM: full access for Terraform to manage roles and OIDC
            {
            Sid      = "IAMAccess"
            Effect   = "Allow"
            Action   = ["iam:*"]
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
