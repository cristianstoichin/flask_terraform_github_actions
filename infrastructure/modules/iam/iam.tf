resource "aws_iam_role" "lambda_role" {
  name = "${var.application}-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = var.tags
}

resource "aws_iam_policy" "policy" {
  name        = "${var.application}-iam-policy-${var.environment}"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      for statement in var.policy_statements : {
        Action   = statement.actions
        Effect   = statement.effect
        Resource = statement.resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy.arn
}