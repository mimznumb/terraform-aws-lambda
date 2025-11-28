# Integration Tests Using Examples

## Overview

Tests deploy and validate the actual examples to ensure they work correctly.

## Tests

### Test 1: Simple Lambda Example
- Deploys `examples/simple-lambda`
- Verifies Lambda function is created
- Validates outputs

### Test 2: Secrets Manager Lambda Example
- Deploys `examples/secrets-manager-lambda`
- Creates a demo secret
- Verifies Lambda with Secrets Manager permissions
- Validates all outputs

## Running Tests

```bash
# Run both tests
terraform test

# Verbose output
terraform test -verbose
```

## What Happens

1. Tests deploy the complete examples
2. Verify resources are created correctly
3. Automatically clean up after completion

## Manual Testing

After deployment, you can also test the examples manually:

```bash
# Deploy simple example
cd examples/simple-lambda
terraform init && terraform apply

# Invoke it
aws lambda invoke \
  --function-name hello-world-lambda \
  --payload '{"test": "data"}' \
  response.json

# Deploy secrets example
cd examples/secrets-manager-lambda
terraform init && terraform apply

# Invoke it (retrieves the secret)
aws lambda invoke \
  --function-name secrets-manager-lambda \
  response.json
```

## Cost

< $0.01 per test run
