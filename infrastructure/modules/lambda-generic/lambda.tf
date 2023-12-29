#----------------------------------------------------------
#   Lambda
#----------------------------------------------------------

resource "aws_cloudwatch_log_group" "python_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = var.lambda_log_retention

  tags = var.tags
}


resource "aws_s3_object" "source_code" {
  key         = var.lambda_s3_key
  bucket      = var.bucket_name
  source      = var.lambda_archive_name
  kms_key_id  = var.kms_encryption_key
  source_hash = filemd5("${var.lambda_archive_name}")
}

resource "aws_lambda_function" "python_lambda_function" {
  function_name     = var.lambda_name
  runtime           = "python3.10"
  s3_bucket         = var.bucket_arn
  s3_key            = aws_s3_object.source_code.key
  s3_object_version = aws_s3_object.source_code.version_id
  handler           = var.lambda_handler
  architectures = [
    "arm64"
  ]
  memory_size = var.lambda_memory_size
  role        = var.lambda_role_arn
  timeout     = var.lambda_timeout
  environment {
    variables = var.variables
  }
  layers = var.layers != [] ? var.layers : null

  depends_on = [
    aws_s3_object.source_code
  ]
  tags = var.tags
}