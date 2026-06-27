output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role (use as AWS_ROLE_ARN secret)"
  value       = aws_iam_role.github_actions.arn
}
