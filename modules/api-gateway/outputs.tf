output "base_url" {
  value = aws_apigatewayv2_stage.hn-lambda.invoke_url
}