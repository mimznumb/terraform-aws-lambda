variable "function_name" {
  description = "Name of the Lambda function to invoke"
  type        = string
}

variable "payload" {
  description = "JSON payload to send to Lambda"
  type        = string
  default     = "{}"
}

# Use null_resource with local-exec to invoke Lambda
resource "null_resource" "invoke_lambda" {
  triggers = {
    function_name = var.function_name
    payload       = var.payload
    timestamp     = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws lambda invoke \
        --function-name ${var.function_name} \
        --payload '${var.payload}' \
        --cli-binary-format raw-in-base64-out \
        response.json > /dev/null 2>&1
    EOT
  }
}

# Read the response file
data "local_file" "lambda_response" {
  filename = "${path.module}/response.json"

  depends_on = [null_resource.invoke_lambda]
}

output "lambda_response" {
  description = "Response from Lambda invocation"
  value       = data.local_file.lambda_response.content
}

output "invocation_timestamp" {
  description = "Timestamp of Lambda invocation"
  value       = null_resource.invoke_lambda.triggers.timestamp
}
