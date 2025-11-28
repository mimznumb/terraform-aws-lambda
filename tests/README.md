# Terraform AWS Lambda Module Tests

Two types of tests for comprehensive coverage:

## 1. Unit Tests (Mock - No AWS)

**Run locally without credentials:**
```bash
terraform test -filter=tests/unit.tftest.hcl
```

**Features:**
- ✅ 10 test cases
- ✅ Mocked AWS provider
- ✅ No credentials needed
- ✅ Runs in seconds
- ✅ Perfect for PRs

**Tests cover:**
- Basic configuration
- Different runtimes (Python, Node.js)
- Memory & timeout settings
- Environment variables
- Custom IAM policies
- VPC configuration
- Tags
- Lambda layers
- S3 deployment source
- Default values

## 2. Integration Tests (Real AWS)

**Requires AWS credentials:**
```bash
terraform test -filter=tests/integration.tftest.hcl
```

**Features:**
- ✅ Deploys actual examples
- ✅ Invokes Lambda functions
- ✅ Validates responses
- ✅ E2E testing

**Tests:**
1. Simple Lambda - Deploy & invoke
2. Secrets Manager - Create secret, deploy Lambda, verify retrieval

## Running All Tests

```bash
terraform test  # Runs both unit and integration tests
```

## CI/CD

- **Unit tests**: Run on every PR (fast feedback)
- **Integration tests**: Run on main branch only (real AWS)

## Cost

- **Unit tests**: $0 (mocked)
- **Integration tests**: <$0.01 per run
