resource "aws_api_gateway_method" "api_proxy_method" {
  rest_api_id          = var.rest_api_id
  resource_id          = var.rest_api_resource_id
  http_method          = var.http_method
  authorization        = var.authorization_mode
  authorizer_id        = var.authorization_mode == "None" ? null : "${var.authorizer_id}"
  request_validator_id = var.validator_id == "" ? null : "${var.validator_id}"
  request_parameters = var.http_method == "GET" ? var.request_params : null
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id                   = "${var.rest_api_id}"
  resource_id                   = "${var.rest_api_resource_id}"
  http_method = "${aws_api_gateway_method.api_proxy_method.http_method}"
  type                    = var.integration_type
  uri                     = "${var.lambda_arn}"
  integration_http_method = "POST"
  depends_on = [
    aws_api_gateway_method.api_proxy_method
  ]
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id                   = "${var.rest_api_id}"
  resource_id = "${var.rest_api_resource_id}"
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = "200"
  response_models = {
      "application/json" = "Empty"
  }
  response_parameters = {
       "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_integration.main, aws_api_gateway_method.api_proxy_method
  ]
}

#APIG Lambda Permission
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = var.path_part != "" ? var.http_method != "ANY" ? "${var.rest_api_id_execution_arn}/*/${var.http_method}/${var.path_part}" : "${var.rest_api_id_execution_arn}/*/*/*" : "${var.rest_api_id_execution_arn}/*/${var.http_method}"
}