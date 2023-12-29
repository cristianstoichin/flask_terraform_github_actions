resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id                   = "${var.rest_api_id}"
  resource_id                   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
  depends_on = [aws_api_gateway_resource.resource]
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id                   = "${var.rest_api_id}"
  resource_id                   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  status_code   = "200"
  response_models = {
      "application/json" = "Empty"
  }
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.options_method, aws_api_gateway_resource.resource]
}
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id                   = "${var.rest_api_id}"
  resource_id                   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  type          = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_resource.resource, aws_api_gateway_method.options_method]
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id                   = "${var.rest_api_id}"
  resource_id                   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  status_code   = "200"
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'*'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_resource.resource, aws_api_gateway_method.options_method, aws_api_gateway_method_response.options_200]
}