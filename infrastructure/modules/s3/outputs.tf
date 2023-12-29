output "s3_bucket_name" {
  value = "${var.application}-${var.environment}"
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.python_lambda.bucket
}

output "s3_bucket_id" {
  value = aws_s3_bucket.python_lambda.id
}

output "s3_bucket_key_arn" {
  #value = aws_kms_key.s3_key.arn
  value = "arn:aws:kms:us-west-2:048117287255:key/eefa1e87-f566-40dc-8ee4-cad41dde20b6"
}