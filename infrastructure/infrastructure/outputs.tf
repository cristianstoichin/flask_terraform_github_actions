output "lambda_url" {
  value = module.lambda_function_register_backend.lambda_invoke_arn
}