# Terraform AWS Lambda Module

A simple and flexible Terraform module for creating AWS Lambda functions with best practices built-in.

## Features

- ✅ Automatic IAM role creation with least privilege
- ✅ CloudWatch Logs integration with configurable retention
- ✅ VPC support for private networking
- ✅ Dead Letter Queue configuration
- ✅ Lambda triggers/permissions management
- ✅ Custom IAM policies support
- ✅ Lambda Layers support
- ✅ Concurrent execution limits
- ✅ Support for both local files and S3-based deployments

## Usage

### Basic Example

```hcl
module "lambda" {
  source = "path/to/terraform-aws-lambda"

  function_name = "my-lambda-function"
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"

  environment_variables = {
    ENV = "production"
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Example with VPC and Custom IAM Policy

```hcl
module "lambda_with_vpc" {
  source = "path/to/terraform-aws-lambda"

  function_name = "my-vpc-lambda"
  handler       = "app.handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 512

  s3_bucket = "my-lambda-bucket"
  s3_key    = "lambdas/my-function.zip"

  vpc_config = {
    subnet_ids         = ["subnet-12345", "subnet-67890"]
    security_group_ids = ["sg-12345"]
  }

  custom_iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/my-table"
      }
    ]
  })

  environment_variables = {
    TABLE_NAME = "my-table"
    REGION     = "us-east-1"
  }

  log_retention_days = 14

  tags = {
    Environment = "production"
  }
}
```

### Example with API Gateway Trigger

```hcl
module "lambda_api" {
  source = "path/to/terraform-aws-lambda"

  function_name = "api-handler"
  handler       = "handler.main"
  runtime       = "nodejs18.x"
  filename      = "api-handler.zip"

  allowed_triggers = {
    APIGateway = {
      principal  = "apigateway.amazonaws.com"
      source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
    }
  }

  tags = {
    Service = "api"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | Name of the Lambda function | `string` | n/a | yes |
| handler | Lambda function handler | `string` | `"index.handler"` | no |
| runtime | Lambda function runtime | `string` | `"python3.11"` | no |
| timeout | Lambda function timeout in seconds | `number` | `30` | no |
| memory_size | Lambda function memory size in MB | `number` | `128` | no |
| filename | Path to the Lambda deployment package (zip file) | `string` | `null` | no |
| s3_bucket | S3 bucket containing the Lambda deployment package | `string` | `null` | no |
| s3_key | S3 key of the Lambda deployment package | `string` | `null` | no |
| s3_object_version | S3 object version of the Lambda deployment package | `string` | `null` | no |
| description | Description of the Lambda function | `string` | `""` | no |
| environment_variables | Environment variables for the Lambda function | `map(string)` | `{}` | no |
| vpc_config | VPC configuration for the Lambda function | `object` | `null` | no |
| dead_letter_config | Dead letter queue configuration | `object` | `null` | no |
| reserved_concurrent_executions | Reserved concurrent executions for the Lambda function | `number` | `-1` | no |
| layers | List of Lambda Layer ARNs to attach to the function | `list(string)` | `[]` | no |
| log_retention_days | CloudWatch Logs retention period in days | `number` | `7` | no |
| custom_iam_policy | Custom IAM policy JSON document to attach to the Lambda role | `string` | `null` | no |
| allowed_triggers | Map of allowed triggers to create Lambda permissions | `map(object)` | `{}` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | Name of the Lambda function |
| function_arn | ARN of the Lambda function |
| invoke_arn | Invoke ARN of the Lambda function |
| qualified_arn | Qualified ARN of the Lambda function |
| version | Latest published version of the Lambda function |
| role_arn | ARN of the IAM role created for the Lambda function |
| role_name | Name of the IAM role created for the Lambda function |
| log_group_name | Name of the CloudWatch Log Group |
| log_group_arn | ARN of the CloudWatch Log Group |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Testing

This module includes comprehensive test coverage with both unit and integration tests.

### Quick Start

```bash
# Run unit tests (no AWS credentials needed - uses mocks)
terraform test -filter=tests/unit.tftest.hcl

# Run integration tests (requires AWS credentials)
terraform test -filter=tests/integration.tftest.hcl
```

### Test Coverage

- ✅ **17 Unit Tests** - Fast, local validation with mocked AWS provider
- ✅ **5 Integration Tests** - Real AWS resource creation and validation
- ✅ **CI/CD Ready** - GitHub Actions workflow included
- ✅ **Registry Ready** - Automated testing in Terraform Cloud Registry

### Documentation

- **[Tests README](tests/README.md)** - Detailed testing guide and examples
- **[Terraform Cloud Testing](TERRAFORM_CLOUD_TESTING.md)** - Registry publishing and automated testing

### Example: Testing Locally

```bash
# Clone the repository
git clone https://github.com/yourorg/terraform-aws-lambda
cd terraform-aws-lambda

# Run all tests
terraform init
terraform test

# Test a specific example
cd examples/simple-lambda
terraform init
terraform plan
```

## Notes


- Either `filename` OR (`s3_bucket` and `s3_key`) must be provided for the Lambda deployment package
- The module automatically creates a CloudWatch Log Group with configurable retention
- VPC execution role is automatically attached when `vpc_config` is provided
- The IAM role follows the principle of least privilege and only includes necessary permissions

## License

MIT
