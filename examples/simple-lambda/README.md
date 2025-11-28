# Simple Lambda Example

This example demonstrates how to use the Lambda module to create a basic Lambda function.

## Usage

1. Package the Lambda code:
```bash
cd examples/simple-lambda
zip lambda.zip index.py
```

2. Initialize Terraform:
```bash
terraform init
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## What's Created

- AWS Lambda function named `hello-world-lambda`
- IAM role with basic execution permissions
- CloudWatch Log Group for function logs

## Testing

After deployment, you can test the Lambda function using AWS CLI:

```bash
aws lambda invoke --function-name hello-world-lambda output.json
cat output.json
```

## Cleanup

```bash
terraform destroy
```
