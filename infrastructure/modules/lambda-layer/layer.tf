resource "aws_s3_object" "source_code_layers" {
  key         = var.bucket_key
  bucket      = var.bucket_name
  source      = var.source_key
  source_hash = filemd5("${var.source_key}")
  kms_key_id  = var.kms_encryption_key
}

resource "aws_lambda_layer_version" "python_requirements" {
  layer_name          = var.layer_name
  compatible_runtimes = ["python3.9", "python3.10"]
  s3_bucket           = var.bucket_id
  s3_key              = aws_s3_object.source_code_layers.key
  source_code_hash    = "${filebase64sha256(var.source_key)}"
  compatible_architectures = [
    "arm64", "x86_64"
  ]
  #s3_object_version = aws_s3_object.source_code_layers.version_id
  depends_on = [
    aws_s3_object.source_code_layers
  ]
}
