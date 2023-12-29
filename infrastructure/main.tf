provider "aws" {
  region = local.region
}

locals {
  region = var.region
}

###########################################################
#  Data
###########################################################

data "aws_lambda_layer_version" "flask_layer" {
  layer_name = "flask"
}


###########################################################
#  Dynamodb table
###########################################################

module "dynamodb_table" {
  source          = "./modules/dynamodb"
  application     = var.application
  environment     = var.environment
  billing_mode    = "PAY_PER_REQUEST"
  read_capacity   = ""
  write_capacity  = ""
  projection_type = "ALL"
  hash_key        = "PK"
  range_key       = "RK"
  attribute_sets = [{
    name = "PK"
    type = "S"
    },
    {
      name = "RK"
      type = "S"
  }]
  global_secondary_indexes = []
  tags                     = local.default_tags
}

###########################################################
#  S3 Artifact Bucket
###########################################################

module "s3_artifact_bucket" {
  source = "./modules/s3"
  application = "${var.application}-python-lambda"
  environment = var.environment
  tags        = local.default_tags
}

###########################################################
#  Lambda Role
###########################################################

module "iam_lambda_task_execution_role" {
  source      = "./modules/iam"
  application = var.application
  environment = var.environment
  policy_statements = [
    {
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["arn:aws:logs:*:*:*"]
      effect    = "Allow"
    },
    {
      actions   = ["ssm:GetParameter"]
      resources = ["*"]
      effect    = "Allow"
    },
    {
      actions   = ["ses:SendEmail"]
      resources = ["*"]
      effect    = "Allow"
    },
    {
      actions   = ["S3:PutObject"]
      resources = ["*"]
      effect    = "Allow"
    },
    {
      actions   = ["cloudfront:CreateInvalidation"]
      resources = ["*"]
      effect    = "Allow"
    },
    {
      actions = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem", "dynamodb:Scan", "dynamodb:Query", "dynamodb:DescribeTable"]
      resources = [
        "${module.dynamodb_table.dynamodb_table_arn}"
      ]
      effect = "Allow"
    }
  ]
  tags = local.default_tags
  depends_on = [
    module.dynamodb_table
  ]
}

###########################################################
#  Lambda Layer
###########################################################

module "flask_lambda_layer" {
  source             = "./modules/lambda-layer"
  bucket_key         = "layers/builds/flask/flask_lambda_layer.zip"
  bucket_name        = module.s3_artifact_bucket.s3_bucket_name
  source_key         = "flask_lambda_layer.zip"
  kms_encryption_key = module.s3_artifact_bucket.s3_bucket_key_arn
  layer_name         = "flask"
  bucket_id          = module.s3_artifact_bucket.s3_bucket_id
  depends_on = [
    module.s3_artifact_bucket
  ]
}

module "awsgi_lambda_layer" {
  source             = "./modules/lambda-layer"
  bucket_key         = "layers/builds/awsgi/awsgi_lambda_layer.zip"
  bucket_name        = module.s3_artifact_bucket.s3_bucket_name
  source_key         = "awsgi_lambda_layer.zip"
  kms_encryption_key = module.s3_artifact_bucket.s3_bucket_key_arn
  layer_name         = "awsgi"
  bucket_id          = module.s3_artifact_bucket.s3_bucket_id
  depends_on = [
    module.s3_artifact_bucket
  ]
}

###########################################################
#  Lambdas
###########################################################

# Demo Lambda
module "lambda_function_demo" {
  source               = "./modules/lambda-generic"
  environment          = var.environment
  bucket_name          = module.s3_artifact_bucket.s3_bucket_name
  bucket_arn           = module.s3_artifact_bucket.s3_bucket_arn
  lambda_s3_key        = "demo/builds/demo_lambda.zip"
  lambda_archive_name  = "demo_lambda.zip"
  lambda_log_retention = var.lambda_log_retention
  kms_encryption_key   = module.s3_artifact_bucket.s3_bucket_key_arn
  lambda_name          = "demo-lambda-${var.environment}"
  lambda_role_arn      = module.iam_lambda_task_execution_role.iam_role_arn
  lambda_timeout       = var.lambda_timeout
  lambda_handler       = "endpoints.${var.lambda_handler}"
  lambda_memory_size   = var.lambda_memory_size
  tags                 = local.default_tags
  layers = [
    "${module.flask_lambda_layer.lambda_layer_arn}",
    "${module.awsgi_lambda_layer.lambda_layer_arn}"
  ]
  variables = {
    environment = var.environment,
    table_name  = module.dynamodb_table.dynamodb_table_name
  }
  depends_on = [
    module.s3_artifact_bucket, module.iam_lambda_task_execution_role, module.flask_lambda_layer, module.awsgi_lambda_layer
  ]
}

###########################################################
#  ApiG Audit Service
###########################################################

module "api_gateway_demo" {
  source           = "./modules/apig"
  application      = var.application
  environment      = var.environment
  endpoint_type    = var.endpoint_type
  hosted_zone_name = var.hosted_zone_name
  sub_domain       = "api"
  tags             = local.default_tags
  depends_on = [
    module.lambda_function_demo
  ]
}

#Validators section
module "api_gateway_resource_validator_get" {
  source                  = "./modules/apig-request-validator"
  rest_api_id             = module.api_gateway_demo.rest_api_id
  validator_name          = "get-validator"
  validate_body           = false
  validate_request_params = false
}

#Proxy endpoint
module "api_gateway_resource_flask_proxy" {
  source      = "./modules/apig-resource"
  rest_api_id = module.api_gateway_demo.rest_api_id
  parent_id   = module.api_gateway_demo.rest_api_root_resource_id
  path_part   = "{proxy+}"
  depends_on = [
    module.api_gateway_demo
  ]
}

#Url get endpoint
module "api_gateway_method_flask_proxy" {
  source                    = "./modules/apig-method-proxy"
  rest_api_id               = module.api_gateway_demo.rest_api_id
  rest_api_resource_id      = module.api_gateway_resource_flask_proxy.resource_id
  authorization_mode        = "NONE"
  http_method               = "ANY"
  integration_type          = "AWS_PROXY"
  authorizer_id             = ""
  request_params            = {}
  lambda_arn                = module.lambda_function_demo.lambda_invoke_arn
  function_name             = module.lambda_function_demo.lambda_function_name
  path_part                 = "{proxy+}"
  rest_api_id_execution_arn = module.api_gateway_demo.rest_api_id_execution_arn
  validator_id              = module.api_gateway_resource_validator_get.request_validator_id
  depends_on = [
    module.api_gateway_demo, module.api_gateway_resource_validator_get, module.lambda_function_demo, module.api_gateway_resource_flask_proxy
  ]
}

#Deployment stage
resource "aws_api_gateway_deployment" "deployment_stage_demo" {
  rest_api_id = module.api_gateway_demo.rest_api_id
  stage_name  = var.api_stage_name

  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = timestamp()
  }

  depends_on = [
    module.api_gateway_demo,
    module.api_gateway_method_flask_proxy
  ]
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = module.api_gateway_demo.rest_api_id
  stage_name  = var.api_stage_name
  domain_name = module.api_gateway_demo.domain_name
  base_path   = ""
  depends_on = [
    aws_api_gateway_deployment.deployment_stage_demo, module.api_gateway_demo
  ]
}