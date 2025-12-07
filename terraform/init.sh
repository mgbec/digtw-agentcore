#!/bin/bash
# Terraform initialization script with backend configuration

set -e

ENVIRONMENT=${1:-dev}

echo "🚀 Initializing Terraform for environment: $ENVIRONMENT"

# Check if backend config file exists
BACKEND_CONFIG="backend-${ENVIRONMENT}.tfbackend"

if [ ! -f "$BACKEND_CONFIG" ]; then
    echo "❌ Error: Backend config file not found: $BACKEND_CONFIG"
    echo ""
    echo "Available environments:"
    ls -1 backend-*.tfbackend 2>/dev/null | sed 's/backend-//g' | sed 's/.tfbackend//g' | sed 's/^/  - /'
    exit 1
fi

echo "📦 Using backend config: $BACKEND_CONFIG"
echo ""

# Initialize Terraform
terraform init -backend-config="$BACKEND_CONFIG" -reconfigure

echo ""
echo "✅ Terraform initialized successfully!"
echo ""
echo "Next steps:"
echo "  1. Review changes: terraform plan"
echo "  2. Deploy: terraform apply"
echo "  3. Get outputs: terraform output"
