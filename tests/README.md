# Integration Tests Using Examples

## Overview

Tests deploy examples **and invoke the Lambda functions** to verify they work end-to-end.

## Tests

### Test 1: Simple Lambda
1. Deploys `examples/simple-lambda`
2. **Invokes the Lambda** using `aws_lambda_invocation` data source
3. Verifies status code 200
4. Validates response contains expected message

### Test 2: Secrets Manager Lambda
1. Deploys `examples/secrets-manager-lambda` (creates secret + Lambda)
2. **Invokes the Lambda** to retrieve the secret
3. Verifies status code 200
4. **Validates the secret value matches** what was created

## Running Tests

```bash
terraform test
```

## What Happens

1. Deploy simple Lambda example → Invoke it → Verify response ✅
2. Deploy secrets Lambda + secret → Invoke it → Verify secret retrieval ✅
3. Auto-cleanup

## Cost

< $0.01 per test run (2 Lambda invocations + resources)
