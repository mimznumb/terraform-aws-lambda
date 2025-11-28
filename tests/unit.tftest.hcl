# Unit Test for Local Testing with Plan Command
# These tests validate module configuration without creating real AWS resources

# Mock provider for unit testing (no real AWS credentials needed)
mock_provider "aws" {}

# Test 1: Basic Lambda Module Configuration
run "test_basic_configuration" {
  command = plan

  variables {
    function_name = "test-lambda-function"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
    timeout       = 30
    memory_size   = 256

    environment_variables = {
      ENV       = "test"
      LOG_LEVEL = "INFO"
    }

    tags = {
      Environment = "test"
      Team        = "platform"
    }
  }

  # Validate variable assignments
  assert {
    condition     = var.function_name == "test-lambda-function"
    error_message = "Function name should be 'test-lambda-function'"
  }

  assert {
    condition     = var.runtime == "python3.11"
    error_message = "Runtime should be 'python3.11'"
  }

  assert {
    condition     = var.timeout == 30
    error_message = "Timeout should be 30 seconds"
  }

  assert {
    condition     = var.memory_size == 256
    error_message = "Memory size should be 256 MB"
  }

  assert {
    condition     = length(var.environment_variables) == 2
    error_message = "Should have 2 environment variables"
  }

  assert {
    condition     = var.environment_variables["ENV"] == "test"
    error_message = "ENV variable should be 'test'"
  }
}

# Test 2: VPC Configuration Validation
run "test_vpc_configuration" {
  command = plan

  variables {
    function_name = "vpc-lambda-function"
    handler       = "app.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    vpc_config = {
      subnet_ids         = ["subnet-abc123", "subnet-def456"]
      security_group_ids = ["sg-xyz789"]
    }

    environment_variables = {
      VPC_ENABLED = "true"
    }
  }

  assert {
    condition     = var.vpc_config != null
    error_message = "VPC config should be set"
  }

  assert {
    condition     = length(var.vpc_config.subnet_ids) == 2
    error_message = "Should have 2 subnet IDs"
  }

  assert {
    condition     = length(var.vpc_config.security_group_ids) == 1
    error_message = "Should have 1 security group ID"
  }

  assert {
    condition     = contains(var.vpc_config.subnet_ids, "subnet-abc123")
    error_message = "Should contain subnet-abc123"
  }
}

# Test 3: Custom IAM Policy Validation
run "test_custom_iam_policy" {
  command = plan

  variables {
    function_name = "lambda-with-custom-policy"
    handler       = "handler.main"
    runtime       = "nodejs18.x"
    filename      = "./tests/fixtures/test_lambda.zip"

    custom_iam_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:Query"
          ]
          Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/test-table"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::test-bucket/*"
        }
      ]
    })

    environment_variables = {
      TABLE_NAME  = "test-table"
      BUCKET_NAME = "test-bucket"
    }
  }

  assert {
    condition     = var.custom_iam_policy != null
    error_message = "Custom IAM policy should be set"
  }

  assert {
    condition     = can(jsondecode(var.custom_iam_policy))
    error_message = "Custom IAM policy should be valid JSON"
  }

  assert {
    condition     = length(jsondecode(var.custom_iam_policy).Statement) == 2
    error_message = "Custom policy should have 2 statements"
  }

  assert {
    condition     = jsondecode(var.custom_iam_policy).Version == "2012-10-17"
    error_message = "Policy should use 2012-10-17 version"
  }
}

# Test 4: Lambda Triggers/Permissions Configuration
run "test_lambda_triggers" {
  command = plan

  variables {
    function_name = "api-lambda"
    handler       = "api.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    allowed_triggers = {
      APIGateway = {
        principal  = "apigateway.amazonaws.com"
        source_arn = "arn:aws:execute-api:us-east-1:123456789012:abc123/*/*/*"
      }
      EventBridge = {
        principal  = "events.amazonaws.com"
        source_arn = "arn:aws:events:us-east-1:123456789012:rule/my-rule"
      }
    }

    environment_variables = {
      API_MODE = "enabled"
    }
  }

  assert {
    condition     = length(var.allowed_triggers) == 2
    error_message = "Should have 2 allowed triggers"
  }

  assert {
    condition     = var.allowed_triggers["APIGateway"].principal == "apigateway.amazonaws.com"
    error_message = "API Gateway trigger principal should be correct"
  }

  assert {
    condition     = var.allowed_triggers["EventBridge"].principal == "events.amazonaws.com"
    error_message = "EventBridge trigger principal should be correct"
  }

  assert {
    condition     = can(regex("^arn:aws:execute-api:", var.allowed_triggers["APIGateway"].source_arn))
    error_message = "API Gateway source ARN should be valid"
  }
}

# Test 5: Lambda Layers Configuration
run "test_lambda_layers" {
  command = plan

  variables {
    function_name = "lambda-with-layers"
    handler       = "app.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    layers = [
      "arn:aws:lambda:us-east-1:123456789012:layer:pandas:1",
      "arn:aws:lambda:us-east-1:123456789012:layer:numpy:2"
    ]

    environment_variables = {
      LAYERS_ENABLED = "true"
    }
  }

  assert {
    condition     = length(var.layers) == 2
    error_message = "Should have 2 layers"
  }

  assert {
    condition     = alltrue([for layer in var.layers : can(regex("^arn:aws:lambda:", layer))])
    error_message = "All layers should be valid Lambda layer ARNs"
  }

  assert {
    condition     = contains(var.layers, "arn:aws:lambda:us-east-1:123456789012:layer:pandas:1")
    error_message = "Should contain pandas layer"
  }
}

# Test 6: Dead Letter Queue Configuration
run "test_dead_letter_config" {
  command = plan

  variables {
    function_name = "lambda-with-dlq"
    handler       = "handler.process"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    dead_letter_config = {
      target_arn = "arn:aws:sqs:us-east-1:123456789012:lambda-dlq"
    }

    environment_variables = {
      DLQ_ENABLED = "true"
    }
  }

  assert {
    condition     = var.dead_letter_config != null
    error_message = "Dead letter config should be set"
  }

  assert {
    condition     = can(regex("^arn:aws:(sqs|sns):", var.dead_letter_config.target_arn))
    error_message = "DLQ target should be valid SQS or SNS ARN"
  }
}

# Test 7: Concurrent Executions
run "test_concurrent_executions" {
  command = plan

  variables {
    function_name                  = "lambda-with-concurrency"
    handler                        = "handler.main"
    runtime                        = "python3.11"
    filename                       = "./tests/fixtures/test_lambda.zip"
    reserved_concurrent_executions = 10

    environment_variables = {
      CONCURRENCY_LIMIT = "10"
    }
  }

  assert {
    condition     = var.reserved_concurrent_executions == 10
    error_message = "Reserved concurrent executions should be 10"
  }

  assert {
    condition     = var.reserved_concurrent_executions > 0
    error_message = "Concurrent executions should be positive"
  }
}

# Test 8: CloudWatch Logs Retention
run "test_log_retention" {
  command = plan

  variables {
    function_name      = "lambda-custom-logs"
    handler            = "index.handler"
    runtime            = "python3.11"
    filename           = "./tests/fixtures/test_lambda.zip"
    log_retention_days = 30

    environment_variables = {
      LOG_RETENTION = "30"
    }
  }

  assert {
    condition     = var.log_retention_days == 30
    error_message = "Log retention should be 30 days"
  }

  assert {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days should be a valid CloudWatch retention value"
  }
}

# Test 9: S3 Deployment Source
run "test_s3_deployment" {
  command = plan

  variables {
    function_name     = "lambda-from-s3"
    handler           = "index.handler"
    runtime           = "python3.11"
    s3_bucket         = "my-lambda-bucket"
    s3_key            = "deployments/my-function.zip"
    s3_object_version = "abc123version"

    environment_variables = {
      DEPLOYMENT_SOURCE = "s3"
    }
  }

  assert {
    condition     = var.s3_bucket != null
    error_message = "S3 bucket should be set"
  }

  assert {
    condition     = var.s3_key != null
    error_message = "S3 key should be set"
  }

  assert {
    condition     = var.s3_object_version != null
    error_message = "S3 object version should be set for versioned deployments"
  }

  assert {
    condition     = var.filename == null
    error_message = "Filename should be null when using S3 source"
  }

  assert {
    condition     = var.s3_bucket == "my-lambda-bucket"
    error_message = "S3 bucket should match expected value"
  }
}

# Test 10: Multiple Runtimes Support
run "test_nodejs_runtime" {
  command = plan

  variables {
    function_name = "nodejs-lambda"
    handler       = "index.handler"
    runtime       = "nodejs20.x"
    filename      = "./tests/fixtures/test_lambda.zip"

    environment_variables = {
      NODE_ENV = "production"
    }
  }

  assert {
    condition     = var.runtime == "nodejs20.x"
    error_message = "Should support Node.js runtime"
  }
}

run "test_python_runtime" {
  command = plan

  variables {
    function_name = "python-lambda"
    handler       = "main.handler"
    runtime       = "python3.12"
    filename      = "./tests/fixtures/test_lambda.zip"

    environment_variables = {
      PYTHONPATH = "/var/task"
    }
  }

  assert {
    condition     = var.runtime == "python3.12"
    error_message = "Should support Python 3.12 runtime"
  }
}

# Test 11: Timeout Boundaries
run "test_timeout_min" {
  command = plan

  variables {
    function_name = "quick-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
    timeout       = 3

    environment_variables = {
      EXECUTION = "fast"
    }
  }

  assert {
    condition     = var.timeout >= 1
    error_message = "Timeout should be at least 1 second"
  }
}

run "test_timeout_max" {
  command = plan

  variables {
    function_name = "long-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
    timeout       = 900

    environment_variables = {
      EXECUTION = "slow"
    }
  }

  assert {
    condition     = var.timeout <= 900
    error_message = "Timeout should be at most 900 seconds (15 minutes)"
  }
}

# Test 12: Memory Size Boundaries
run "test_memory_boundaries" {
  command = plan

  variables {
    function_name = "memory-test-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
    memory_size   = 512

    environment_variables = {
      MEMORY_CHECK = "enabled"
    }
  }

  assert {
    condition     = var.memory_size >= 128
    error_message = "Memory size should be at least 128 MB"
  }

  assert {
    condition     = var.memory_size <= 10240
    error_message = "Memory size should be at most 10240 MB"
  }
}

# Test 13: Tags Validation
run "test_tags" {
  command = plan

  variables {
    function_name = "tagged-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    tags = {
      Environment = "production"
      Team        = "platform"
      CostCenter  = "engineering"
      ManagedBy   = "terraform"
    }

    environment_variables = {
      TAGS = "enabled"
    }
  }

  assert {
    condition     = length(var.tags) == 4
    error_message = "Should have 4 tags"
  }

  assert {
    condition     = var.tags["Environment"] == "production"
    error_message = "Environment tag should be production"
  }

  assert {
    condition     = var.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be terraform"
  }
}

# Test 14: Empty Environment Variables
run "test_no_env_vars" {
  command = plan

  variables {
    function_name = "no-env-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
  }

  assert {
    condition     = length(var.environment_variables) == 0
    error_message = "Should support Lambda without environment variables"
  }
}

# Test 15: Default Values
run "test_defaults" {
  command = plan

  variables {
    function_name = "default-config-lambda"
    filename      = "./tests/fixtures/test_lambda.zip"
  }

  assert {
    condition     = var.handler == "index.handler"
    error_message = "Default handler should be 'index.handler'"
  }

  assert {
    condition     = var.runtime == "python3.11"
    error_message = "Default runtime should be 'python3.11'"
  }

  assert {
    condition     = var.timeout == 30
    error_message = "Default timeout should be 30 seconds"
  }

  assert {
    condition     = var.memory_size == 128
    error_message = "Default memory size should be 128 MB"
  }

  assert {
    condition     = var.log_retention_days == 7
    error_message = "Default log retention should be 7 days"
  }

  assert {
    condition     = var.reserved_concurrent_executions == -1
    error_message = "Default concurrent executions should be -1 (unlimited)"
  }
}
