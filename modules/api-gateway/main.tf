# module for api gateway

terraform {
  #required_version = ">= 0.12.20, < 2.0"
  required_providers {
    aws = ">= 2.31, < 4.0"
  }
}

# creates an HTTP api
resource "aws_apigatewayv2_api" "hn-lambda" {
  name          = "serverless_lambda_gateway"
  protocol_type = "HTTP"
}

# The aws_apigatewayv2_stage resource specifies a stage for an API. Each stage is a named
# reference to a deployment of the API and is made available for client applications to call
resource "aws_apigatewayv2_stage" "hn-lambda" {
  api_id      = aws_apigatewayv2_api.hn-lambda.id
  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# The resource aws_apigatewayv2_integration creates an integration for an API
resource "aws_apigatewayv2_integration" "hello" {
  api_id = aws_apigatewayv2_api.hn-lambda.id
  integration_uri    = var.integration_uri
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# api routes
resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.hn-lambda.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello.id}"
}

# cloudwatch log group for the gateway to write logs
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.hn-lambda.name}"
  retention_in_days = 30
}

# add permission for gateway to invoke lambda function
resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowExecutionFromAPIGateway"
  action       = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.hn-lambda.execution_arn}/*/*"
}
