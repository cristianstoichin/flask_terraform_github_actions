#resource "aws_kms_key" "s3_key" {
#  description             = "This key is used to encrypt bucket objects"
#  count = var.create_kms_key == true ? 1 : 0
#  deletion_window_in_days = 7
#}

resource "aws_s3_bucket" "python_lambda" {
  bucket        = "${var.application}-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "s3_terraform_versioning" {
  bucket = aws_s3_bucket.python_lambda.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_encryption" {
  bucket = aws_s3_bucket.python_lambda.bucket

  rule {
    apply_server_side_encryption_by_default {
      #kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.python_lambda.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

variable "tags" {
  type = map(any)
}