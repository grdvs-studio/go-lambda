variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "endpoints" {
  description = "List of API endpoints. Each endpoint should have path, http_methods, lambda_invoke_arn, and lambda_function_name"
  type = list(object({
    path                 = string
    http_methods         = list(string)
    lambda_invoke_arn    = string
    lambda_function_name = string
    authorization        = string
    cors_enabled         = bool
  }))
  default = []
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = string
  default     = "*"
}

variable "cors_allowed_methods" {
  description = "Allowed methods for CORS"
  type        = string
  default     = "GET,OPTIONS"
}

variable "cors_allowed_headers" {
  description = "Allowed headers for CORS"
  type        = string
  default     = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
}

variable "enable_waf" {
  description = "Enable WAF for API Gateway"
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "Rate limit for WAF (requests per 5 minutes per IP)"
  type        = number
  default     = 2000
}

variable "waf_name" {
  description = "Name for the WAF Web ACL"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}
