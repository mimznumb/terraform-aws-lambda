variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.11"
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

variable "filename" {
  description = "Path to the Lambda deployment package (zip file)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the Lambda deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the Lambda deployment package"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "dead_letter_config" {
  description = "Dead letter queue configuration"
  type = object({
    target_arn = string
  })
  default = null
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for the Lambda function"
  type        = number
  default     = -1
}

variable "layers" {
  description = "List of Lambda Layer ARNs to attach to the function"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 7
}

variable "custom_iam_policy" {
  description = "Custom IAM policy JSON document to attach to the Lambda role"
  type        = string
  default     = null
}

variable "allowed_triggers" {
  description = "Map of allowed triggers to create Lambda permissions"
  type = map(object({
    principal  = string
    source_arn = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
