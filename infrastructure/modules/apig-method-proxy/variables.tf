
variable "rest_api_id" {
  type = string
}

variable "rest_api_resource_id" {
  type = string
}

variable "authorization_mode" {
  type = string
}

variable "authorizer_id" {
  type = string
}

variable "http_method" {
  type = string
}

variable "integration_type" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "function_name" {
  type = string
}

variable "path_part" {
  type = string
}

variable "rest_api_id_execution_arn" {
  type = string
}

variable "validator_id" {
  type = string
}

variable "request_params" {
  type = map(any)
}
