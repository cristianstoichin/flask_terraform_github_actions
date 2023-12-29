resource "aws_api_gateway_request_validator" "validator" {
  name                        = var.validator_name
  rest_api_id                 = var.rest_api_id
  validate_request_body       = var.validate_body
  validate_request_parameters = var.validate_request_params
}