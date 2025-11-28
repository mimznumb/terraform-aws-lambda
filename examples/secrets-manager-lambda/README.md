# Secrets Manager Lambda Example

This example demonstrates how to use the Lambda module to create a function that accesses AWS Secrets Manager.

## What's Created

- AWS Secrets Manager secret with a demo value
- Lambda function with IAM permissions to read the secret
- Lambda configured with the secret ARN as an environment variable

## Usage

```bash
# Initialize and deploy
terraform init
terraform apply

# The Lambda function can now access the secret
```

## Testing the Lambda

After deployment, you can invoke the Lambda to retrieve the secret:

```bash
aws lambda invoke \
  --function-name secrets-manager-lambda \
  response.json

cat response.json | jq
```

The Lambda will retrieve and return the secret value from Secrets Manager.

## Cleanup

```bash
terraform destroy
```

Note: The secret is configured with `recovery_window_in_days = 0` for immediate deletion in this demo.
