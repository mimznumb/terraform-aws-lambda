# Integration Tests Using Examples
# Test 1: Deploy and test simple-lambda example
# Test 2: Deploy and test secrets-manager-lambda example

# Test 1: Simple Lambda Example
run "simple_lambda_example" {
  command = apply

  module {
    source = "./examples/simple-lambda"
  }

  # Verify Lambda was created
  assert {
    condition     = output.lambda_arn != ""
    error_message = "Lambda ARN should be created from simple-lambda example"
  }

  assert {
    condition     = output.lambda_name == "hello-world-lambda"
    error_message = "Lambda name should match example configuration"
  }
}

# Test 2: Secrets Manager Lambda Example
run "secrets_manager_example" {
  command = apply

  module {
    source = "./examples/secrets-manager-lambda"
  }

  # Verify Lambda was created
  assert {
    condition     = output.lambda_arn != ""
    error_message = "Lambda ARN should be created from secrets-manager example"
  }

  assert {
    condition     = output.lambda_name == "secrets-manager-lambda"
    error_message = "Lambda name should match example configuration"
  }

  # Verify secret was created
  assert {
    condition     = output.secret_arn != ""
    error_message = "Secret ARN should be created"
  }
}
