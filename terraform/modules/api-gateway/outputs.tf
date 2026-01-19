output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "invoke_url" {
  description = "Base invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.this.arn
}

output "endpoint_urls" {
  description = "Map of endpoint paths to their full URLs"
  value = {
    for idx, endpoint in var.endpoints :
    endpoint.path => "${aws_api_gateway_stage.this.invoke_url}/${endpoint.path}"
  }
}

output "waf_arn" {
  description = "ARN of the WAF Web ACL (if enabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.api_gateway[0].arn : null
}

output "waf_id" {
  description = "ID of the WAF Web ACL (if enabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.api_gateway[0].id : null
}
