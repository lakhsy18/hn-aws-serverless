# ----------------------------------------------------------------------------------------------------------------------
# Terraform root module to instantiate a lambda-function and api-gateway to create an http api with
# with serverless lambda function as the backend.
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# aws provider setup
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 1.3.0"
    }
  }
  backend "s3" {
    bucket = "terraform-hn-s3-serverless-backend"
    key = "hn-infrastructure"
    region = "eu-central-1"
  }
  #required_version = "~> 1.0"
}

# ----------------------------------------------------------------------------------------------------------------------
# A deployment package is a ZIP archive that contains lambda function code and dependencies.
# ----------------------------------------------------------------------------------------------------------------------

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/hello.py"
  output_path = "${path.module}/python/hello.py.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# deploy the lambda function using child module 'lambda-function'
# ----------------------------------------------------------------------------------------------------------------------

module "lambda-function" {
  source = "./modules/lambda-function"
  function_name = "python-function"
  description   = "Lambda function that returns an HTTP response."
  filename      = data.archive_file.lambda.output_path
  runtime       = "python3.8"
  handler       = "hello.lambda_handler"
  lambda_role_name = "role_lambda"
  timeout       = 30
  memory_size   = 128
}

# ----------------------------------------------------------------------------------------------------------------------
# deploy the api gateway using child module 'api-gateway'
# ----------------------------------------------------------------------------------------------------------------------
module "api_gateway" {
  source = "./modules/api-gateway"
  integration_uri = module.lambda-function.function.invoke_arn
  function_name = "python-function"
}

