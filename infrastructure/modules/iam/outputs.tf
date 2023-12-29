output "iam_role_arn" {
  description = "The role arn"
  value       = aws_iam_role.lambda_role.arn
}