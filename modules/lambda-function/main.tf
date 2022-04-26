# This lambda-function module takes a .zip file and uploads it to AWS Lambda
# to create a serverless function.
provider "aws" {
  region = "eu-central-1"
}

terraform {
  #required_version = ">= 0.12.20, < 2.0"
  required_providers {
    aws = ">= 2.31, < 4.0"
  }
}

locals {
  s3_bucket         = var.filename != null ? null : var.s3_bucket
  s3_key            = var.filename != null ? null : var.s3_key
  s3_object_version = var.filename != null ? null : var.s3_object_version
  source_code_hash = var.source_code_hash != null ? var.source_code_hash : var.filename != null ? filebase64sha256(var.filename) : null
}

# Create an aws lambda function
resource "aws_lambda_function" "hn-lambda" {
  count = var.module_enabled ? 1 : 0

  function_name = var.function_name
  description   = var.description
  filename         = var.filename
  s3_bucket         = local.s3_bucket
  s3_key            = local.s3_key
  s3_object_version = local.s3_object_version
  source_code_hash = local.source_code_hash
  runtime = var.runtime
  handler = var.handler
  layers  = var.layer_arns
  publish = var.publish
  role    = aws_iam_role.hn-lambda_role.arn
  #lambda_role_name = var.lambda_role_name
  memory_size = var.memory_size
  timeout     = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  kms_key_arn = var.kms_key_arn

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [true] : []

    content {
      variables = var.environment_variables
    }
  }
}

# IAM role which dictates what other AWS services the Lambda function
 # may access.
resource "aws_iam_role" "hn-lambda_role" {
   name = var.lambda_role_name

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# attach permissions to the aws lambda function
locals {
  permissions = {
    for permission in var.permissions : permission.statement_id => {
      statement_id       = permission.statement_id
      action             = try(permission.action, "lambda:InvokeFunction")
      event_source_token = try(permission.event_source_token, null)
      principal          = permission.principal
      qualifier          = try(permission.qualifier, null)
      source_account     = try(permission.source_account, null)
      source_arn         = permission.source_arn
    }
  }
}

resource "aws_lambda_permission" "permission" {
  for_each = var.module_enabled ? local.permissions : {}

  action             = each.value.action
  event_source_token = each.value.event_source_token
  function_name      = aws_lambda_function.hn-lambda[0].function_name
  principal          = each.value.principal
  qualifier          = each.value.qualifier
  statement_id       = each.key
  source_account     = each.value.source_account
  source_arn         = each.value.source_arn
}

