# Helper module to create a test secret in Secrets Manager

variable "secret_name" {
  description = "Name of the secret to create"
  type        = string
  default     = "test-lambda-secret"
}

variable "secret_value" {
  description = "Value of the secret"
  type        = string
  default     = "my-super-secret-value-123"
}

resource "aws_secretsmanager_secret" "test_secret" {
  name                    = var.secret_name
  description             = "Test secret for Lambda integration testing"
  recovery_window_in_days = 0 # Immediate deletion for tests
}

resource "aws_secretsmanager_secret_version" "test_secret_version" {
  secret_id     = aws_secretsmanager_secret.test_secret.id
  secret_string = var.secret_value
}

output "secret_arn" {
  value = aws_secretsmanager_secret.test_secret.arn
}

output "secret_value" {
  value = var.secret_value
}
