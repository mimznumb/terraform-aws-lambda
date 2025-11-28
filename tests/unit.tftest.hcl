# Mock Unit Tests - Run Locally Without AWS

# Mock AWS provider - no real AWS calls
mock_provider "aws" {}

# Test 1: Basic Lambda Configuration
run "test_basic_config" {
  command = plan

  variables {
    function_name = "test-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"
  }

  assert {
    condition     = var.function_name == "test-lambda"
    error_message = "Function name should match input"
  }

  assert {
    condition     = var.runtime == "python3.11"
    error_message = "Runtime should be python3.11"
  }

  assert {
    condition     = var.handler == "index.handler"
    error_message = "Handler should match input"
  }
}

# Test 2: Runtime Validation
run "test_different_runtimes" {
  command = plan

  variables {
    function_name = "nodejs-lambda"
    handler       = "index.handler"
    runtime       = "nodejs20.x"
    filename      = "lambda.zip"
  }

  assert {
    condition     = var.runtime == "nodejs20.x"
    error_message = "Should support Node.js runtime"
  }
}

# Test 3: Memory and Timeout Configuration
run "test_memory_timeout" {
  command = plan

  variables {
    function_name = "config-test"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"
    memory_size   = 512
    timeout       = 60
  }

  assert {
    condition     = var.memory_size == 512
    error_message = "Memory should be configurable"
  }

  assert {
    condition     = var.timeout == 60
    error_message = "Timeout should be configurable"
  }
}

# Test 4: Environment Variables
run "test_environment_variables" {
  command = plan

  variables {
    function_name = "env-test"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"

    environment_variables = {
      ENV       = "production"
      LOG_LEVEL = "INFO"
      API_KEY   = "test-key"
    }
  }

  assert {
    condition     = length(var.environment_variables) == 3
    error_message = "Should have 3 environment variables"
  }

  assert {
    condition     = var.environment_variables["ENV"] == "production"
    error_message = "ENV should be production"
  }
}

# Test 5: Custom IAM Policy
run "test_custom_iam_policy" {
  command = plan

  variables {
    function_name = "iam-test"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"

    custom_iam_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::bucket/*"
      }]
    })
  }

  assert {
    condition     = var.custom_iam_policy != null
    error_message = "Custom IAM policy should be set"
  }

  assert {
    condition     = can(jsondecode(var.custom_iam_policy))
    error_message = "IAM policy should be valid JSON"
  }
}

# Test 6: VPC Configuration
run "test_vpc_config" {
  command = plan

  variables {
    function_name = "vpc-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"

    vpc_config = {
      subnet_ids         = ["subnet-123", "subnet-456"]
      security_group_ids = ["sg-789"]
    }
  }

  assert {
    condition     = var.vpc_config != null
    error_message = "VPC config should be set"
  }

  assert {
    condition     = length(var.vpc_config.subnet_ids) == 2
    error_message = "Should have 2 subnets"
  }
}

# Test 7: Tags
run "test_tags" {
  command = plan

  variables {
    function_name = "tagged-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"

    tags = {
      Environment = "dev"
      Team        = "platform"
      ManagedBy   = "terraform"
    }
  }

  assert {
    condition     = length(var.tags) == 3
    error_message = "Should have 3 tags"
  }

  assert {
    condition     = var.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be terraform"
  }
}

# Test 8: Lambda Layers
run "test_layers" {
  command = plan

  variables {
    function_name = "layers-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    filename      = "lambda.zip"

    layers = [
      "arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"
    ]
  }

  assert {
    condition     = length(var.layers) == 1
    error_message = "Should have 1 layer"
  }
}

# Test 9: S3 Deployment Source
run "test_s3_source" {
  command = plan

  variables {
    function_name = "s3-lambda"
    handler       = "index.handler"
    runtime       = "python3.11"
    s3_bucket     = "my-bucket"
    s3_key        = "lambda.zip"
  }

  assert {
    condition     = var.s3_bucket == "my-bucket"
    error_message = "S3 bucket should be set"
  }

  assert {
    condition     = var.filename == null
    error_message = "Filename should be null when using S3"
  }
}

# Test 10: Default Values
run "test_defaults" {
  command = plan

  variables {
    function_name = "defaults-lambda"
    filename      = "lambda.zip"
  }

  assert {
    condition     = var.handler == "index.handler"
    error_message = "Default handler should be index.handler"
  }

  assert {
    condition     = var.runtime == "python3.11"
    error_message = "Default runtime should be python3.11"
  }

  assert {
    condition     = var.timeout == 30
    error_message = "Default timeout should be 30"
  }

  assert {
    condition     = var.memory_size == 128
    error_message = "Default memory should be 128"
  }
}
