variable "environment" {
  description = "Environment name to use"
  type        = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "kms_encryption_key" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_s3_key" {
  type = string
}

variable "lambda_archive_name" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "lambda_memory_size" {
  type = number
}

variable "lambda_timeout" {
  type = number
}

variable "lambda_log_retention" {
  description = "CLoudwatch log retention period - 1,7,14,30, etc."
  type        = number
}

variable "tags" {
  type = map(any)
}

variable "layers" {
  type = list(any)
}

variable "variables" {
  type = map(any)
}