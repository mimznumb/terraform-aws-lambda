provider "aws" {
  region = "us-east-1"
}

# Example VPC (in practice, use your existing VPC)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "lambda" {
  name_prefix = "lambda-sg-"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-security-group"
  }
}

module "vpc_lambda" {
  source = "../../"

  function_name = "vpc-lambda-function"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/lambda.zip"
  timeout       = 60
  memory_size   = 256

  vpc_config = {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  custom_iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })

  environment_variables = {
    BUCKET_NAME = "my-bucket"
    ENVIRONMENT = "production"
  }

  log_retention_days = 14

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

output "lambda_arn" {
  value = module.vpc_lambda.function_arn
}

output "lambda_role_arn" {
  value = module.vpc_lambda.role_arn
}
