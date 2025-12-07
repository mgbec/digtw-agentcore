#!/bin/bash
# Prepare agent for deployment (no knowledge base upload needed)
# Context is embedded directly in agent instructions via Terraform

set -e

ENVIRONMENT=${1:-dev}
PROJECT_NAME=${2:-twin}

echo "🤖 Preparing Agentcore Agent for ${PROJECT_NAME}-${ENVIRONMENT}"

cd terraform

# Get agent ID
AGENT_ID=$(terraform output -raw agentcore_agent_id 2>/dev/null || echo "")

if [ -z "$AGENT_ID" ]; then
    echo "❌ Error: Could not find agent ID. Have you deployed Terraform?"
    echo "Run: terraform apply"
    exit 1
fi

echo "📦 Agent ID: $AGENT_ID"

# Prepare the agent (this is done automatically by Terraform, but can be triggered manually)
echo "🔄 Preparing agent..."
aws bedrock-agent prepare-agent \
    --agent-id "$AGENT_ID" \
    --region ${AWS_REGION:-us-east-1}

echo "✅ Agent prepared successfully!"
echo ""
echo "🎉 Your Agentcore agent is ready to use!"
echo ""
echo "Test it with:"
echo "  curl -X POST <your-api-endpoint>/agentcore/chat \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"message\":\"Hello!\"}'"
