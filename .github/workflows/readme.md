## Overview

This directory includes the Github actions job that can be used to deploy the required infrastructure to host the flask application in AWS. 

### [1.deploy-api-infra.yml](1.deploy-api-infra.yml)

The Github Action job allows you to either Plan, Deploy or Destroy the terraform template. You must also setup the region where you want it to be deployed in [dev.tfvars](https://github.com/cristianstoichin/flask_terraform_github_actions/blob/main/infrastructure/variables/dev.tfvars#L1).

This Github Action is designed to create the resources defined [here](https://github.com/cristianstoichin/react-ci-cd-terraform/tree/main/infrastructure#spa-template)

Before running the Job (manual trigger), you must first have the following Github Repo Secrets setup:

1. `CERT_ARN`
   - This is the ARN (Amazon Resource Name) of the SSL certificate that should have been generated following the execution of the previous GitHub Actions job.
2. `DEPLOYMENT_ROLE_ARN`
   - This must be an existing Role in your AWS account that will allow the job to run the `aws cloudformation deploy` command.
      - Typically, this role is granted Admin permissions in AWS. However, be aware that this could pose a security risk. AWS recommends using the least privileged permissions for enhanced security.
3. `hosted_zone_name`
   - This is a pre-requisite before running the deployment. You must have a Route53 hosted zone (public) that will be used to validate the ssl certificate.
4. `bucket_name' this can also be a secret but in this example I simply hardcoded the value. This must be your desired subdomain name for the website. Ex: react-terraform.  

#### AWS Route53 Example

<p align="center">
  <img src="../../assets/hosted-zone.png" alt="Ec2">
</p>

#### Github Secrets Example

<p align="center">
  <img src="../../assets/secrets.png" alt="Ec2">
</p>
