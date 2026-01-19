# API Gateway REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description != "" ? var.api_description : "API Gateway for ${var.api_name}"
}

# Create resources and methods for each endpoint
resource "aws_api_gateway_resource" "endpoints" {
  for_each = {
    for idx, endpoint in var.endpoints : idx => endpoint
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path
}

# Create methods for each endpoint
resource "aws_api_gateway_method" "endpoints" {
  for_each = {
    for combo in flatten([
      for endpoint_idx, endpoint in var.endpoints : [
        for method in endpoint.http_methods : {
          key           = "${endpoint_idx}-${method}"
          endpoint_idx  = endpoint_idx
          method        = method
          path          = endpoint.path
          authorization = endpoint.authorization
        }
      ]
    ]) : combo.key => combo
  }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.endpoints[each.value.endpoint_idx].id
  http_method   = each.value.method
  authorization = each.value.authorization
}

# Lambda permissions for each endpoint
resource "aws_lambda_permission" "endpoints" {
  for_each = {
    for combo in flatten([
      for endpoint_idx, endpoint in var.endpoints : [
        for method in endpoint.http_methods : {
          key                  = "${endpoint_idx}-${method}"
          endpoint_idx         = endpoint_idx
          method               = method
          lambda_function_name = endpoint.lambda_function_name
        }
      ]
    ]) : combo.key => combo
  }

  statement_id  = "AllowAPIGatewayInvoke-${each.value.endpoint_idx}-${each.value.method}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# API Gateway integrations for Lambda
resource "aws_api_gateway_integration" "lambda" {
  for_each = {
    for combo in flatten([
      for endpoint_idx, endpoint in var.endpoints : [
        for method in endpoint.http_methods : {
          key               = "${endpoint_idx}-${method}"
          endpoint_idx      = endpoint_idx
          method            = method
          lambda_invoke_arn = endpoint.lambda_invoke_arn
        }
      ]
    ]) : combo.key => combo
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.endpoints[each.value.endpoint_idx].id
  http_method = aws_api_gateway_method.endpoints[each.value.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn
}

# OPTIONS methods for CORS (only for endpoints with CORS enabled)
resource "aws_api_gateway_method" "options" {
  for_each = {
    for idx, endpoint in var.endpoints : idx => endpoint
    if endpoint.cors_enabled
  }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.endpoints[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method integration (mock response for CORS)
resource "aws_api_gateway_integration" "options" {
  for_each = {
    for idx, endpoint in var.endpoints : idx => endpoint
    if endpoint.cors_enabled
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.endpoints[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# OPTIONS method response
resource "aws_api_gateway_method_response" "options" {
  for_each = {
    for idx, endpoint in var.endpoints : idx => endpoint
    if endpoint.cors_enabled
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.endpoints[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS integration response
resource "aws_api_gateway_integration_response" "options" {
  for_each = {
    for idx, endpoint in var.endpoints : idx => endpoint
    if endpoint.cors_enabled
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.endpoints[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = aws_api_gateway_method_response.options[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${var.cors_allowed_headers}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${var.cors_allowed_methods}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allowed_origins}'"
  }

  depends_on = [aws_api_gateway_integration.options]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.options,
    aws_api_gateway_integration_response.options,
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  lifecycle {
    create_before_destroy = true
  }

  # Force new deployment when endpoints change
  triggers = {
    endpoints = jsonencode(var.endpoints)
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}

# WAF Web ACL for API Gateway (conditional)
resource "aws_wafv2_web_acl" "api_gateway" {
  count = var.enable_waf ? 1 : 0

  name        = var.waf_name != "" ? var.waf_name : "${var.api_name}-waf"
  description = "WAF for API Gateway ${var.api_name}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Common Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - IP Reputation List
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_name != "" ? var.waf_name : "${var.api_name}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = var.waf_name != "" ? var.waf_name : "${var.api_name}-waf"
    Environment = var.environment
  }
}

# WAF Association with API Gateway (conditional)
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = aws_wafv2_web_acl.api_gateway[0].arn

  depends_on = [
    aws_api_gateway_stage.this,
    aws_wafv2_web_acl.api_gateway,
  ]
}
