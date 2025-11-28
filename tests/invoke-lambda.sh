#!/bin/bash
# Lambda Invocation Script for Integration Testing
# Usage: ./invoke-lambda.sh <function-name> [payload-file]

set -e

FUNCTION_NAME="${1}"
PAYLOAD_FILE="${2:-tests/fixtures/test_payload.json}"

if [ -z "$FUNCTION_NAME" ]; then
    echo "Usage: $0 <function-name> [payload-file]"
    echo "Example: $0 terraform-test-lambda"
    exit 1
fi

echo "Invoking Lambda function: $FUNCTION_NAME"

if [ ! -f "$PAYLOAD_FILE" ]; then
    echo "Creating default payload..."
    cat > "$PAYLOAD_FILE" << 'EOF'
{
  "test_key": "test_value",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
fi

echo "Using payload from: $PAYLOAD_FILE"

# Invoke the Lambda function
aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload file://"$PAYLOAD_FILE" \
    --cli-binary-format raw-in-base64-out \
    response.json

# Check if invocation was successful
if [ $? -eq 0 ]; then
    echo "✅ Lambda invocation successful!"
    echo ""
    echo "Response:"
    cat response.json | jq '.' 2>/dev/null || cat response.json
    echo ""
    
    # Extract and display status code if present
    STATUS_CODE=$(cat response.json | jq -r '.statusCode' 2>/dev/null)
    if [ "$STATUS_CODE" == "200" ]; then
        echo "✅ Status Code: $STATUS_CODE"
    elif [ ! -z "$STATUS_CODE" ] && [ "$STATUS_CODE" != "null" ]; then
        echo "⚠️  Status Code: $STATUS_CODE"
    fi
else
    echo "❌ Lambda invocation failed!"
    exit 1
fi
