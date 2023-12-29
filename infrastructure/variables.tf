variable "application" {
  description = "Application name to use"
  type        = string
}

variable "environment" {
  description = "Environment name to use"
  type        = string
}

variable "region" {
  description = "AWS region to use"
  type        = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_memory_size" {
  type = number
}

variable "lambda_timeout" {
  type = number
}

variable "lambda_log_retention" {
  description = "Cloudwatch log retention period - 1,7,14,30, etc."
  type        = number
}

variable "endpoint_type" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "layer_name" {
  type = string
}

variable "table_name" {
  type = string
}