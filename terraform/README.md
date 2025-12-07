# Terraform Configuration

Infrastructure as Code for the Digital Twin project with dual backend support (Traditional + Agentcore).

## 🚀 Quick Start

### Initialize Terraform

```bash
# For dev environment
terraform init -backend-config=backend-dev.tfbackend

# For prod environment
terraform init -backend-config=backend-prod.tfbackend

# For test environment
terraform init -backend-config=backend-test.tfbackend
```

### Deploy

```bash
# Review changes
terraform plan

# Apply changes
terraform apply
```

## 📁 Files

### Main Configuration
- `main.tf` - Traditional backend resources (Lambda, API Gateway, S3, CloudFront)
- `agentcore.tf` - Agentcore backend resources (Bedrock Agent, Lambda, API routes)
- `variables.tf` - Input variables
- `agentcore_variables.tf` - Agentcore-specific variables
- `output.tf` - Output values
- `versions.tf` - Provider versions and configuration
- `backend.tf` - S3 backend configuration

### Backend Configuration Files
- `backend-dev.tfbackend` - Dev environment backend config
- `backend-prod.tfbackend` - Prod environment backend config
- `backend-test.tfbackend` - Test environment backend config

### Variable Files
- `terraform.tfvars` - Environment-specific variable values

## 🏗️ Architecture

### Traditional Backend
- Lambda function with FastAPI
- API Gateway HTTP API
- S3 for conversation memory
- CloudFront distribution
- Direct Bedrock API calls

### Agentcore Backend (NEW)
- Bedrock Agent with embedded context
- Lambda function with FastAPI
- API Gateway routes (`/agentcore/*`)
- Built-in conversation memory
- No Knowledge Base (cost-optimized)

## 🔧 Configuration

### Required Variables

Edit `terraform.tfvars`:

```hcl
project_name           = "twin"
environment            = "dev"
default_aws_region     = "us-east-1"
use_custom_domain      = false
root_domain            = ""
bedrock_model_id       = "amazon.nova-lite-v1:0"
agentcore_foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"
```

### Backend Configuration

The S3 backend stores Terraform state remotely. Backend config files specify:
- `bucket` - S3 bucket for state storage
- `key` - Path to state file (environment-specific)
- `region` - AWS region

## 📊 Outputs

After deployment, get important values:

```bash
# All outputs
terraform output

# Specific outputs
terraform output api_gateway_url
terraform output agentcore_agent_id
terraform output agentcore_api_endpoint
terraform output cloudfront_url
```

## 🔄 Updating Context

When you update files in `backend/data/`:
- `facts.json`
- `style.txt`
- `summary.txt`

Run `terraform apply` to update the Agentcore agent instructions with the new context.

## 💰 Cost Optimization

This configuration is optimized to avoid expensive resources:
- ❌ No OpenSearch Serverless (~$175/month saved)
- ❌ No Knowledge Base infrastructure
- ✅ Context embedded in agent instructions (FREE)

Expected costs: ~$5-20/month (usage-based)

## 🐛 Troubleshooting

### Backend Initialization Errors

**Error: "Value must not contain //"**
- Use the backend config file: `terraform init -backend-config=backend-dev.tfbackend`

**Error: "Missing region value"**
- Ensure backend config file has `region = "us-east-1"`

### Provider Errors

**Error: "Missing required provider"**
- Run `terraform init` to download providers

### Agent Errors

**Error: "Context files not found"**
- Ensure `backend/data/` files exist before running `terraform apply`

## 📚 Documentation

- **Deployment Checklist**: `../DEPLOYMENT_CHECKLIST.md`
- **Quick Start**: `../QUICK_START_AGENTCORE.md`
- **Full Guide**: `../AGENTCORE_MIGRATION_GUIDE.md`
- **Cost Details**: `../AGENTCORE_COST_OPTIMIZED.md`

## 🔐 Security

- IAM roles follow least-privilege principle
- S3 buckets have public access blocked (except frontend)
- CORS configured for specific origins
- Session IDs validated

## 🚀 Deployment Workflow

```bash
# 1. Initialize
terraform init -backend-config=backend-dev.tfbackend

# 2. Review
terraform plan

# 3. Deploy
terraform apply

# 4. Get outputs
terraform output

# 5. Test
curl -X POST $(terraform output -raw api_gateway_url)/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}'

curl -X POST $(terraform output -raw agentcore_api_endpoint)/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}'
```

## 📝 Notes

- Both backends are deployed simultaneously
- No breaking changes to existing infrastructure
- Traditional backend continues to work unchanged
- Agentcore backend is additive
- Easy to remove Agentcore if not needed (delete `agentcore.tf`)

---

**Version:** 0.2.0  
**Last Updated:** December 2025
