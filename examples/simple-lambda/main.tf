provider "aws" {
  region = "us-east-1"
}

module "simple_lambda" {
  source = "../../"

  function_name = "hello-world-lambda"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda.zip"

  environment_variables = {
    GREETING = "Hello from Terraform!"
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

output "lambda_arn" {
  value = module.simple_lambda.function_arn
}

output "lambda_name" {
  value = module.simple_lambda.function_name
}
