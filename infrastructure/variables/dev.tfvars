region = "us-west-2"
environment = "dev"
application = "flask-demo"
lambda_log_retention = 7
lambda_timeout = 25
lambda_memory_size = 512
lambda_handler = "lambda_handler"
endpoint_type = "REGIONAL"
api_stage_name = "v1"
hosted_zone_name="dash-demo.click"
table_name="demo-products-flask"