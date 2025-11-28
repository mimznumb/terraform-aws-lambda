provider "aws" {
  region = "us-east-1"
}

# Create a test secret for demo purposes
resource "aws_secretsmanager_secret" "demo_secret" {
  name                    = "demo-lambda-secret-${formatdate("YYMMDDhhmmss", timestamp())}"
  description             = "Demo secret for Lambda example"
  recovery_window_in_days = 0 # Allows immediate deletion
}

resource "aws_secretsmanager_secret_version" "demo_secret_version" {
  secret_id     = aws_secretsmanager_secret.demo_secret.id
  secret_string = "my-super-secret-value-123"
}

# Deploy Lambda with Secrets Manager access
module "secrets_lambda" {
  source = "../../"

  function_name = "secrets-manager-lambda"
  handler       = "secrets_lambda.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda.zip"

  # Grant Secrets Manager permissions
  custom_iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.demo_secret.arn
    }]
  })

  environment_variables = {
    SECRET_ARN = aws_secretsmanager_secret.demo_secret.arn
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Example     = "secrets-manager"
  }
}

output "lambda_arn" {
  value = module.secrets_lambda.function_arn
}

output "lambda_name" {
  value = module.secrets_lambda.function_name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.demo_secret.arn
}
