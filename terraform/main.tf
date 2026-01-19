terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration is provided via backend.tfvars file
    # Run ../s3-backend.sh first to create the bucket and DynamoDB table
    # Then initialize with: terraform init -backend-config=backend.tfvars
    # 
    # The backend.tfvars file should contain:
    bucket         = "tfstate-f98khg474"
    key            = "health-check-lambda/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Lambda module for health check function
module "health_check_lambda" {
  source = "./modules/lambda"

  function_name = var.lambda_function_name
  zip_path      = var.lambda_zip_path
  environment   = var.environment
  timeout       = 30
  memory_size   = 128
}

# API Gateway module
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name        = "${var.lambda_function_name}-api"
  api_description = "API Gateway for ${var.lambda_function_name}"
  stage_name      = var.stage_name

  endpoints = [
    {
      path                 = "health"
      http_methods         = ["GET"]
      lambda_invoke_arn    = module.health_check_lambda.invoke_arn
      lambda_function_name = module.health_check_lambda.function_name
      authorization        = "NONE"
      cors_enabled         = true
    }
  ]

  cors_allowed_origins = "*"
  cors_allowed_methods = "GET,OPTIONS"
  cors_allowed_headers = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"

  # WAF configuration
  enable_waf     = var.enable_waf
  waf_rate_limit = var.waf_rate_limit
  waf_name       = "${var.lambda_function_name}-waf"
  environment    = var.environment
}
