output "lambda_arn" {
  value = aws_lambda_function.python_lambda_function.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.python_lambda_function.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.python_lambda_function.function_name
}

output "aws_cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.python_lambda_log_group.name
}

output "aws_cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.python_lambda_log_group.arn
}
