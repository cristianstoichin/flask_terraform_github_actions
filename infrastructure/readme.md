## Overview

This directory includes the terraform templates for the flask api. These templates are executed by GitHub Actions to set up the necessary infrastructure for hosting the flask application.

### [Flask Api Template](https://github.com/cristianstoichin/flask_terraform_github_actions/tree/main/infrastructure)

This template is designed to create the following resources in your AWS account:

1. Private S3 bucket to hold Flask code zip file.
2. Lambda to run flask code.
3. Dynamodb Table to store demo products.
4. API Gateway fronting the Lambda flask code.
5. API Gateway custom domain and SSL certificate.
6. Route53 dns friendly name for Custom Domain.

The template is using the [dev.tfvars](https://github.com/cristianstoichin/flask_terraform_github_actions/blob/main/infrastructure/variables/dev.tfvars) as entry parameters. You will need to change these for your needs. 

`Before deploying this to your AWS account, you must have a pre-existing Route53 public hosted zone in place, which is required for validating the certificate.`

The templates are using this [configuration file](https://github.com/cristianstoichin/flask_terraform_github_actions/blob/main/infrastructure/config/backend-dev.hcl) to tell Terraform where the state files are stored. In this case, we use an S3 terraform backend. 

`Before deploying this to your AWS account, you must have a pre-existing S3 bucket created in your AWS account and change` [this value](https://github.com/cristianstoichin/flask_terraform_github_actions/blob/main/infrastructure/config/backend-dev.hcl#L1) `to your bucket's name.`
