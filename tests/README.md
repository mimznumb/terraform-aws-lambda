# Terraform Testing Guide

This directory contains comprehensive tests for the AWS Lambda Terraform module.

## Test Types

### 1. Unit Tests (`unit.tftest.hcl`)
- **Purpose**: Fast, local testing with mocked AWS provider
- **No AWS Resources Created**: Uses mock provider to simulate AWS responses
- **Speed**: Very fast (seconds)
- **Use Case**: Local development, CI/CD validation, rapid iteration

### 2. Integration Tests (`integration.tftest.hcl`)
- **Purpose**: End-to-end testing with real AWS resources
- **AWS Resources Created**: Creates actual Lambda functions and invokes them
- **Speed**: Slower (minutes)
- **Use Case**: Terraform Cloud/Registry automated testing, pre-release validation

## Prerequisites

### For Unit Tests (Local)
- Terraform >= 1.6.0
- No AWS credentials required (uses mocks)

### For Integration Tests (Terraform Cloud)
- Terraform >= 1.6.0
- AWS credentials configured
- AWS CLI installed (for Lambda invocation)
- Appropriate IAM permissions to create Lambda functions, IAM roles, and CloudWatch logs

## Running Tests Locally

### Run Unit Tests (Mocked - No AWS Resources)
```bash
# Run all unit tests
terraform test -filter=tests/unit.tftest.hcl

# Run with verbose output
terraform test -filter=tests/unit.tftest.hcl -verbose

# Run specific test
terraform test -filter=tests/unit.tftest.hcl -run=test_basic_configuration
```

### Run Integration Tests (Real AWS Resources)
```bash
# Set AWS credentials
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key

# Run all integration tests (will create real resources!)
terraform test -filter=tests/integration.tftest.hcl

# Clean up is automatic - the test includes a cleanup run
```

## Running Tests in Terraform Cloud

### Setup for Publishing to Registry

1. **Configure GitHub Repository**
   - Ensure your module follows the naming convention: `terraform-aws-lambda`
   - Tag releases with semantic versioning (e.g., `v1.0.0`)

2. **Terraform Cloud Configuration**
   - Connect your GitHub repository to Terraform Cloud
   - Enable automated testing in your module settings
   - Configure AWS credentials as workspace variables:
     - `AWS_ACCESS_KEY_ID` (sensitive)
     - `AWS_SECRET_ACCESS_KEY` (sensitive)
     - `AWS_REGION` (non-sensitive)

3. **Test Execution**
   - Tests run automatically on:
     - New commits to main/master branch
     - Pull requests
     - Tag creation
   - Integration tests execute in Terraform Cloud workspace
   - Results appear in the module's test tab

### Manual Test Execution in Terraform Cloud

```bash
# From your local machine, trigger remote tests
terraform login
terraform test -cloud-run=auto
```

## Test Coverage

### Unit Tests Cover:
✅ Basic Lambda configuration  
✅ VPC configuration  
✅ Custom IAM policies  
✅ Lambda triggers and permissions  
✅ Lambda layers  
✅ Dead letter queue configuration  
✅ Concurrent execution limits  
✅ CloudWatch logs retention  
✅ S3 deployment sources  
✅ Output validation  

### Integration Tests Cover:
✅ Lambda function creation  
✅ Lambda function invocation  
✅ IAM role creation and permissions  
✅ Environment variables  
✅ CloudWatch log group creation  
✅ VPC configuration (plan only)  
✅ Lambda layers (plan only)  
✅ Resource cleanup  

## Test Structure

### Unit Test Example
```hcl
mock_provider "aws" {
  mock_resource "aws_lambda_function" {
    defaults = {
      arn = "arn:aws:lambda:us-east-1:123456789012:function:mock-function"
      function_name = "mock-function"
    }
  }
}

run "test_name" {
  command = plan
  
  variables {
    function_name = "test-function"
  }
  
  assert {
    condition     = output.function_name == "mock-function"
    error_message = "Function name should match"
  }
}
```

### Integration Test Example
```hcl
run "create_and_invoke_lambda" {
  command = apply
  
  variables {
    function_name = "real-test-lambda"
    runtime       = "python3.11"
    filename      = "./tests/fixtures/test_lambda.zip"
  }
  
  assert {
    condition     = can(regex("^arn:aws:lambda:", output.function_arn))
    error_message = "Should create valid Lambda function"
  }
}
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Terraform Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0
      - name: Run Unit Tests
        run: terraform test -filter=tests/unit.tftest.hcl

  integration-tests:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Run Integration Tests
        run: terraform test -filter=tests/integration.tftest.hcl
```

## Troubleshooting

### Unit Tests Fail with "Provider not found"
- Ensure Terraform version >= 1.6.0
- Mock provider feature requires Terraform 1.6+

### Integration Tests Fail with "Access Denied"
- Check AWS credentials are configured correctly
- Verify IAM permissions for Lambda, IAM, and CloudWatch Logs
- Ensure AWS CLI is installed and configured

### Lambda Invocation Fails
- Check that Lambda function is created successfully
- Verify AWS CLI is available in PATH
- Check Lambda execution role permissions

### Tests Leave Resources Behind
- Integration tests include cleanup run
- Manually clean up with: `terraform destroy -auto-approve`
- Check failed test logs for partial deployments

## Best Practices

1. **Run unit tests frequently** during development (fast feedback)
2. **Run integration tests before releases** (validate real behavior)
3. **Use unique function names** in integration tests (timestamp-based)
4. **Monitor costs** - integration tests create billable resources
5. **Review test output** - assertions provide detailed error messages
6. **Keep test fixtures updated** - sync with latest Lambda runtimes

## Cost Considerations

### Unit Tests
- **Cost**: $0 (no AWS resources created)

### Integration Tests
- **Lambda Function**: ~$0.0000002 per invocation
- **CloudWatch Logs**: ~$0.50 per GB ingested
- **Total per test run**: < $0.01 (typically)

**Note**: Tests automatically clean up resources to minimize costs.

## Additional Resources

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Cloud Testing](https://developer.hashicorp.com/terraform/cloud-docs/registry/test)
- [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
