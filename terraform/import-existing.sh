#!/bin/bash
# Import existing AWS resources into Terraform state

set -e

echo "🔄 Importing existing AWS resources into Terraform state..."
echo ""

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $ACCOUNT_ID"

# Import S3 buckets
echo "📦 Importing S3 buckets..."
terraform import aws_s3_bucket.memory "twin-dev-memory-${ACCOUNT_ID}" 2>/dev/null || echo "  ⚠️  Memory bucket not found or already imported"
terraform import aws_s3_bucket.frontend "twin-dev-frontend-${ACCOUNT_ID}" 2>/dev/null || echo "  ⚠️  Frontend bucket not found or already imported"

# Import IAM role
echo "🔐 Importing IAM roles..."
terraform import aws_iam_role.lambda_role "twin-dev-lambda-role" 2>/dev/null || echo "  ⚠️  Lambda role not found or already imported"

# Import Lambda function if it exists
echo "⚡ Importing Lambda function..."
terraform import aws_lambda_function.api "twin-dev-api" 2>/dev/null || echo "  ⚠️  Lambda function not found or already imported"

# Import API Gateway if it exists
echo "🌐 Importing API Gateway..."
API_ID=$(aws apigatewayv2 get-apis --query "Items[?Name=='twin-dev-api-gateway'].ApiId" --output text 2>/dev/null || echo "")
if [ -n "$API_ID" ]; then
    terraform import aws_apigatewayv2_api.main "$API_ID" 2>/dev/null || echo "  ⚠️  API Gateway already imported"
else
    echo "  ⚠️  API Gateway not found"
fi

echo ""
echo "✅ Import complete! Now run: terraform apply"
