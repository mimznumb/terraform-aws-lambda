# Integration Tests Using Examples
# Tests deploy examples and invoke the Lambda functions to verify they work

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

# Test 1b: Invoke the simple Lambda
run "invoke_simple_lambda" {
  command = apply

  variables {
    function_name = run.simple_lambda_example.lambda_name
  }

  # Invoke Lambda using data source
  module {
    source = "./tests/helpers/lambda-invoker"
  }

  # Verify Lambda executed successfully
  assert {
    condition     = jsondecode(output.response_payload).statusCode == 200
    error_message = "Lambda should return status code 200"
  }

  assert {
    condition     = can(jsondecode(jsondecode(output.response_payload).body).message)
    error_message = "Lambda response should contain message in body"
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

# Test 2b: Invoke the secrets Lambda
run "invoke_secrets_lambda" {
  command = apply

  variables {
    function_name = run.secrets_manager_example.lambda_name
  }

  # Invoke Lambda using data source
  module {
    source = "./tests/helpers/lambda-invoker"
  }

  # Verify Lambda executed successfully
  assert {
    condition     = jsondecode(output.response_payload).statusCode == 200
    error_message = "Secrets Lambda should return status code 200"
  }

  # Verify the secret was retrieved
  assert {
    condition     = can(jsondecode(jsondecode(output.response_payload).body).secret)
    error_message = "Lambda response should contain the retrieved secret"
  }

  assert {
    condition     = jsondecode(jsondecode(output.response_payload).body).secret == "my-super-secret-value-123"
    error_message = "Retrieved secret value should match the created secret"
  }
}
