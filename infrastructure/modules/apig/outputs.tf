output "rest_api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}

output "rest_api_id_execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}

output "domain_name" {
  value = aws_api_gateway_domain_name.custom_domain.domain_name
}