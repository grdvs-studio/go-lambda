output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.health_check_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.health_check_lambda.function_arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway health endpoint"
  value       = module.api_gateway.endpoint_urls["health"]
}

output "api_gateway_invoke_url" {
  description = "Base URL of the API Gateway"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}
