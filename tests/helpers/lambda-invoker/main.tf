# Helper module to invoke Lambda function using data source

variable "function_name" {
  description = "Name of the Lambda function to invoke"
  type        = string
}

variable "payload" {
  description = "JSON payload to send to Lambda"
  type        = string
  default     = "{\"test\": \"data\"}"
}

# Invoke the Lambda function
data "aws_lambda_invocation" "test" {
  function_name = var.function_name
  input         = var.payload
}

output "response_payload" {
  description = "Response from Lambda invocation"
  value       = data.aws_lambda_invocation.test.result
}

output "status_code" {
  description = "Status code from Lambda invocation"
  value       = data.aws_lambda_invocation.test.result_map.StatusCode
}
