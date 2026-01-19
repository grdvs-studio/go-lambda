variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "health-check-lambda"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package (zip file)"
  type        = string
  default     = "../bootstrap.zip"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}
