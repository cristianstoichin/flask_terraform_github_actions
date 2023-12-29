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
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method

  type                    = var.integration_type
  uri                     = var.lambda_arn
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
      {
        "method": "$context.httpMethod",
        "body" : $input.json('$'),
        "headers": {
          #foreach($param in $input.params().header.keySet())
          "$param": "$util.escapeJavaScript($input.params().header.get($param))" #if($foreach.hasNext),#end

          #end
        },
        "queryParams": {
          #foreach($param in $input.params().querystring.keySet())
          "$param": "$util.escapeJavaScript($input.params().querystring.get($param))" #if($foreach.hasNext),#end

          #end
        },
        "pathParams": {
          #foreach($param in $input.params().path.keySet())
          "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end

          #end
        }  
      }
EOF
  }

  depends_on = [
    aws_api_gateway_method.api_proxy_method
  ]
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
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
    aws_api_gateway_integration.main
  ]
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  depends_on = [
    aws_api_gateway_method_response.response_200
  ]
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'*'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "response_400" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = "400"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_integration.main
  ]
}

resource "aws_api_gateway_integration_response" "integration_response_400" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = aws_api_gateway_method_response.response_400.status_code
  selection_pattern = ".*\"statusCode\":400.*"
  depends_on = [
    aws_api_gateway_method_response.response_400
  ]
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'*'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "response_401" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = "401"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_integration.main
  ]
}

resource "aws_api_gateway_integration_response" "integration_response_401" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = aws_api_gateway_method_response.response_401.status_code
  selection_pattern = ".*\"statusCode\":401.*"
  depends_on = [
    aws_api_gateway_method_response.response_401
  ]
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'*'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "response_404" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = "404"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_integration.main
  ]
}

resource "aws_api_gateway_integration_response" "integration_response_404" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = aws_api_gateway_method_response.response_404.status_code
  selection_pattern = ".*\"statusCode\":404.*"
  depends_on = [
    aws_api_gateway_method_response.response_404
  ]
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'*'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "response_500" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = "500"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_integration.main
  ]
}

resource "aws_api_gateway_integration_response" "integration_response_500" {
  rest_api_id = var.rest_api_id
  resource_id = var.rest_api_resource_id
  http_method = aws_api_gateway_method.api_proxy_method.http_method
  status_code = aws_api_gateway_method_response.response_500.status_code
  selection_pattern = ".*\"statusCode\":500.*"
  depends_on = [
    aws_api_gateway_method_response.response_500
  ]
  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'*'",
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

#APIG Lambda Permission
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = var.path_part != "" ? var.http_method != "ANY" ? "${var.rest_api_id_execution_arn}/*/${var.http_method}/${var.path_part}" : "${var.rest_api_id_execution_arn}/*/*/*" : "${var.rest_api_id_execution_arn}/*/${var.http_method}"
}