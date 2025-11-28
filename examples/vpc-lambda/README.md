# VPC Lambda Example

This example demonstrates how to deploy a Lambda function within a VPC with custom IAM permissions.

## Features Demonstrated

- Lambda function in VPC
- Custom security group
- Custom IAM policy for S3 access
- Extended timeout and memory
- Custom log retention

## Usage

1. Package the Lambda code:
```bash
cd examples/vpc-lambda
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

- AWS Lambda function in VPC
- IAM role with custom S3 permissions
- Security group for Lambda
- CloudWatch Log Group with 14-day retention

## Notes

- This example uses the default VPC for simplicity
- In production, replace with your actual VPC and private subnets
- Ensure NAT Gateway or VPC endpoints are configured for external access

## Cleanup

```bash
terraform destroy
```
