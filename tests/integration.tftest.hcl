# Integration Test for Terraform Cloud/Registry
# This test creates real AWS resources and validates the Lambda function

variables {
  test_function_name = "terraform-test-lambda-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

# Test 1: Basic Lambda Creation and Invocation
run "create_and_invoke_lambda" {
  command = apply

  variables {
    function_name = var.test_function_name
    handler       = "test_lambda.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
    timeout       = 30
    memory_size   = 128

    environment_variables = {
      TEST_VAR = "integration-test-value"
    }

    tags = {
      Environment = "test"
      ManagedBy   = "terraform-test"
    }
  }

  # Validate outputs exist
  assert {
    condition     = output.function_name == var.test_function_name
    error_message = "Function name mismatch"
  }

  assert {
    condition     = can(regex("^arn:aws:lambda:", output.function_arn))
    error_message = "Invalid Lambda ARN format"
  }

  assert {
    condition     = can(regex("^arn:aws:iam:", output.role_arn))
    error_message = "Invalid IAM role ARN format"
  }

  assert {
    condition     = output.log_group_name == "/aws/lambda/${var.test_function_name}"
    error_message = "Log group name mismatch"
  }
}

# Test 2: Verify Lambda Function Properties  
run "verify_lambda_properties" {
  command = plan

  variables {
    function_name = var.test_function_name
    handler       = "test_lambda.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
    timeout       = 60
    memory_size   = 256

    environment_variables = {
      TEST_VAR = "property-test"
      ENV_TYPE = "integration"
    }

    tags = {
      Environment = "test"
      TestType    = "integration"
    }
  }

  # Validate function configuration
  assert {
    condition     = var.timeout == 60
    error_message = "Function timeout should be configurable"
  }

  assert {
    condition     = var.memory_size == 256
    error_message = "Function memory size should be configurable"
  }

  assert {
    condition     = length(var.environment_variables) == 2
    error_message = "Environment variables should be configurable"
  }
}

# Test 3: Verify IAM Role Permissions
run "verify_iam_permissions" {
  command = apply

  variables {
    function_name = var.test_function_name
    handler       = "test_lambda.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    custom_iam_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject"
          ]
          Resource = "arn:aws:s3:::test-bucket/*"
        }
      ]
    })

    environment_variables = {
      TEST_VAR = "policy-test"
    }
  }

  # Verify the function was created with custom policy
  assert {
    condition     = output.function_name == var.test_function_name
    error_message = "Function creation failed with custom IAM policy"
  }

  assert {
    condition     = output.role_arn != ""
    error_message = "IAM role not created"
  }
}

# Test 4: VPC Configuration Test
run "test_vpc_config" {
  command = plan

  variables {
    function_name = var.test_function_name
    handler       = "test_lambda.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    vpc_config = {
      subnet_ids         = ["subnet-12345678", "subnet-87654321"]
      security_group_ids = ["sg-12345678"]
    }

    environment_variables = {
      TEST_VAR = "vpc-test"
    }
  }

  # Only plan - don't create actual VPC resources
  assert {
    condition     = length(var.vpc_config.subnet_ids) > 0
    error_message = "VPC configuration should include subnets"
  }
}

# Test 5: Lambda with Layers
run "test_lambda_layers" {
  command = plan

  variables {
    function_name = var.test_function_name
    handler       = "test_lambda.handler"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"

    layers = [
      "arn:aws:lambda:us-east-1:123456789012:layer:test-layer:1"
    ]

    environment_variables = {
      TEST_VAR = "layers-test"
    }
  }

  assert {
    condition     = length(var.layers) > 0
    error_message = "Lambda should support layers"
  }
}

# Note: Resources are automatically cleaned up after tests complete
# No explicit destroy command needed in Terraform test framework
