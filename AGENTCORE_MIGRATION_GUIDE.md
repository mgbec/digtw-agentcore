# AWS Bedrock Agentcore Migration Guide

This guide explains the hybrid deployment where both your original backend and the new Agentcore backend run side-by-side.

## 🏗️ Architecture Overview

### Current Setup (Still Active)
- **Endpoint**: `/chat`, `/health`, `/`
- **Backend**: FastAPI with direct Bedrock API calls
- **Memory**: Manual S3 storage
- **Lambda**: `twin-{env}-api`

### New Agentcore Setup (Parallel)
- **Endpoint**: `/agentcore/chat`, `/agentcore/health`, `/agentcore`
- **Backend**: Bedrock Agentcore with agent orchestration
- **Memory**: Built-in Agentcore memory service (automatic)
- **Lambda**: `twin-{env}-agentcore-api`
- **Agent**: Bedrock Agent with Knowledge Base

## 📦 What Was Added

### Backend Files
1. **`backend/agentcore_server.py`** - New FastAPI server for Agentcore
2. **`backend/agentcore_lambda_handler.py`** - Lambda handler for Agentcore
3. **`backend/agentcore_config.py`** - Agent configuration and instructions
4. **`backend/.env.agentcore`** - Environment variables template

### Terraform Files
1. **`terraform/agentcore.tf`** - All Agentcore resources:
   - Bedrock Agent (digital twin personality)
   - Knowledge Base (facts, style, summary)
   - OpenSearch Serverless collection
   - S3 bucket for knowledge base data
   - IAM roles and policies
   - API Gateway routes (`/agentcore/*`)
   - Lambda function for Agentcore

2. **`terraform/agentcore_variables.tf`** - Configuration variables
3. **`terraform/output.tf`** - Added Agentcore outputs

### Scripts
1. **`scripts/upload_knowledge_base.sh`** - Upload data to knowledge base

## 🚀 Deployment Steps

### Step 1: Deploy Infrastructure

```bash
cd terraform

# Initialize (if needed)
terraform init

# Review changes
terraform plan

# Deploy (this will create Agentcore resources alongside existing ones)
terraform apply
```

This creates:
- ✅ Bedrock Agent (with context embedded in instructions)
- ✅ New Lambda function for Agentcore
- ✅ API Gateway routes at `/agentcore/*`
- ✅ IAM roles and policies

**Note**: We're NOT using a Knowledge Base to avoid OpenSearch Serverless costs (~$175/month). 
Instead, all context from `backend/data/` is embedded directly in the agent instructions via Terraform.

### Step 2: Prepare Agent (Optional)

The agent is automatically prepared during Terraform deployment, but you can manually trigger it:

```bash
# Make script executable
chmod +x scripts/upload_knowledge_base.sh

# Prepare agent
./scripts/upload_knowledge_base.sh dev
```

### Step 3: Get Configuration Values

```bash
cd terraform

# Get agent configuration
terraform output agentcore_agent_id
terraform output agentcore_agent_alias_id
terraform output agentcore_api_endpoint
```

### Step 4: Test Locally (Optional)

```bash
cd backend

# Create .env file with Agentcore settings
cp .env.agentcore .env

# Update with your values from Terraform output
# Edit .env and set:
# AGENTCORE_AGENT_ID=<from terraform output>
# AGENTCORE_AGENT_ALIAS_ID=<from terraform output>

# Install dependencies (if not already done)
pip install -r requirements.txt

# Run Agentcore server on port 8001
python agentcore_server.py
```

Test it:
```bash
curl -X POST http://localhost:8001/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello! Tell me about yourself."}'
```

### Step 5: Update Frontend (Optional)

To let users choose between backends, update your frontend:

```typescript
// Add backend selection
const [backend, setBackend] = useState<'original' | 'agentcore'>('original');

const apiEndpoint = backend === 'agentcore' 
  ? `${API_URL}/agentcore/chat`
  : `${API_URL}/chat`;
```

## 🔄 Comparison: Original vs Agentcore

| Feature | Original Backend | Agentcore Backend |
|---------|-----------------|-------------------|
| **Endpoint** | `/chat` | `/agentcore/chat` |
| **Memory** | Manual S3 management | Automatic (built-in) |
| **Context** | Loaded at runtime | Embedded in agent instructions |
| **Orchestration** | Single API call | Multi-agent capable |
| **Tracing** | Manual logging | Built-in trace data |
| **Scalability** | Lambda limits | Agent orchestration |
| **Cost** | Per-token pricing | Per-token + minimal agent overhead |

## 🧪 Testing Both Backends

### Test Original Backend
```bash
curl -X POST https://your-api-gateway-url/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hi!"}'
```

### Test Agentcore Backend
```bash
curl -X POST https://your-api-gateway-url/agentcore/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hi!"}'
```

### Compare Responses
Both should respond as Ned Flanders, but Agentcore may:
- Have better context retrieval from Knowledge Base
- Include trace information (if enabled)
- Handle complex multi-turn conversations better

## 📊 Monitoring

### Original Backend
- CloudWatch Logs: `/aws/lambda/twin-{env}-api`
- Metrics: Lambda invocations, duration, errors

### Agentcore Backend
- CloudWatch Logs: `/aws/lambda/twin-{env}-agentcore-api`
- Bedrock Agent Traces: Available in response when `AGENTCORE_ENABLE_TRACE=true`
- Knowledge Base: Monitor ingestion jobs in AWS Console

## 💰 Cost Considerations

### Original Backend Costs
- Lambda execution time
- Bedrock API calls (per token)
- S3 storage (minimal)
- API Gateway requests

### Agentcore Backend Costs
- Lambda execution time
- Bedrock Agent invocations (minimal overhead)
- Bedrock API calls (per token)
- API Gateway requests

**Note**: Since we're not using a Knowledge Base, the cost difference is minimal - just the agent invocation overhead. 
This makes Agentcore much more cost-effective while still providing better orchestration and memory management.

## 🎯 Migration Strategy

### Phase 1: Testing (Current)
- ✅ Both backends deployed
- ✅ Test Agentcore with sample traffic
- ✅ Compare quality and performance

### Phase 2: Gradual Rollout
- Route 10% of traffic to Agentcore
- Monitor metrics and user feedback
- Adjust based on results

### Phase 3: Decision Point
**Option A**: Keep both (A/B testing, different use cases)
**Option B**: Migrate fully to Agentcore (remove original)
**Option C**: Keep original (remove Agentcore if not worth cost)

## 🔧 Troubleshooting

### Agent Not Found Error
```
Error: Agentcore agent not found
```
**Solution**: Deploy Terraform first, then update environment variables.

### Agent Responses Lack Context
```
Agent doesn't know about the person
```
**Solution**: Context is loaded from `backend/data/` files during Terraform deployment. If you update these files, run `terraform apply` again to update the agent instructions.

### Lambda Timeout
```
Task timed out after 30 seconds
```
**Solution**: Increase `lambda_timeout` in `terraform/variables.tf` (Agentcore can be slower).

## 🗑️ Removing Agentcore (If Needed)

If you decide not to use Agentcore:

```bash
cd terraform

# Remove Agentcore resources
rm agentcore.tf agentcore_variables.tf

# Update output.tf to remove Agentcore outputs
# (remove the Agentcore section)

# Apply changes
terraform apply
```

## 📚 Additional Resources

- [AWS Bedrock Agentcore Documentation](https://aws.amazon.com/bedrock/agentcore/)
- [Bedrock Agents Developer Guide](https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html)
- [Knowledge Bases for Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html)

## 🎉 Next Steps

1. Deploy Terraform: `cd terraform && terraform apply`
2. Upload knowledge base: `./scripts/upload_knowledge_base.sh dev`
3. Test both endpoints and compare
4. Decide on migration strategy
5. Update frontend if needed

---

**Questions?** Check the troubleshooting section or review the AWS Bedrock documentation.
