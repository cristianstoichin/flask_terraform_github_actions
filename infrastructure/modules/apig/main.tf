data "aws_route53_zone" "hosted_zone" {
  name         =  var.hosted_zone_name
}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.application}-apig-${var.environment}"

  endpoint_configuration {
    types = [var.endpoint_type]
  }
  binary_media_types = ["application/octet-stream"]
  tags = var.tags
}

resource "aws_api_gateway_request_validator" "validator" {
  name                        = "api_gateway_request_validator"
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  validate_request_body       = true
  validate_request_parameters = true
  depends_on = [
    aws_api_gateway_rest_api.api
  ]
}

resource "aws_api_gateway_gateway_response" "response" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  status_code   = "401"
  response_type = "UNAUTHORIZED"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_rest_api.api
  ]
}

#----------------------------------------------------------
#   Certificate
#----------------------------------------------------------
resource "aws_acm_certificate" "cert" {
  domain_name = "${var.sub_domain}.${var.hosted_zone_name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_rest_api.api
  ]
}

resource "aws_route53_record" "cert_validation_dns" {
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  ttl = 300
  depends_on = [
    aws_acm_certificate.cert, aws_api_gateway_rest_api.api
  ]
}

resource "aws_acm_certificate_validation" "cert_validate" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_dns.fqdn]
}

#----------------------------------------------------------
#   Custom Domain
#----------------------------------------------------------

resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name =  "${var.sub_domain}.${var.hosted_zone_name}"
  regional_certificate_arn = aws_acm_certificate.cert.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  depends_on = [
    aws_acm_certificate.cert, aws_route53_record.cert_validation_dns, aws_api_gateway_rest_api.api, aws_acm_certificate_validation.cert_validate
  ]
}

#----------------------------------------------------------
#   Route53
#----------------------------------------------------------
resource "aws_route53_record" "alias" {
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.sub_domain}.${var.hosted_zone_name}"
  type    = "A"
  alias {
    name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id 
    evaluate_target_health = false
  }
  depends_on = [
    aws_api_gateway_domain_name.custom_domain, aws_api_gateway_rest_api.api, aws_acm_certificate.cert
  ]
  lifecycle {
    ignore_changes = [
      zone_id,
    ]
  }
}