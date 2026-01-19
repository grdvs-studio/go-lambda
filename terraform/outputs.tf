output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.health_check.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.health_check.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_stage.stage.invoke_url}/health"
}

output "api_gateway_invoke_url" {
  description = "Base URL of the API Gateway"
  value       = aws_api_gateway_stage.stage.invoke_url
}
