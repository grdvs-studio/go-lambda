variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "zip_path" {
  description = "Path to the Lambda deployment package (zip file)"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "provided.al2023"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "bootstrap"
}

variable "architectures" {
  description = "Lambda architecture"
  type        = list(string)
  default     = ["arm64"]
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "additional_policy_arns" {
  description = "Additional IAM policy ARNs to attach to Lambda role"
  type        = list(string)
  default     = []
}
