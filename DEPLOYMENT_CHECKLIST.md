# Deployment Checklist

Quick checklist before deploying Agentcore.

## ✅ Pre-Deployment Checklist

### 1. Prerequisites
- [ ] AWS CLI configured (`aws sts get-caller-identity`)
- [ ] Terraform installed (`terraform version`)
- [ ] AWS Bedrock access enabled in your region
- [ ] AWS Bedrock Agents access enabled

### 2. Configuration Files
- [ ] `backend/data/facts.json` - Updated with your information
- [ ] `backend/data/style.txt` - Updated with your style
- [ ] `backend/data/summary.txt` - Updated with your summary
- [ ] `terraform/terraform.tfvars` - Configured for your environment

### 3. Review Documentation
- [ ] Read `DECISION_TREE.md` - Choose your backend
- [ ] Read `QUICK_START_AGENTCORE.md` - Understand deployment
- [ ] Read `AGENTCORE_COST_OPTIMIZED.md` - Understand costs

## 🚀 Deployment Steps

### Step 1: Initialize Terraform

**Easy Method:**
```bash
cd terraform
./init.sh dev
```

**Manual Method:**
```bash
cd terraform
terraform init -backend-config=backend-dev.tfbackend
```

**Expected Output:**
- Providers downloaded successfully
- Backend initialized with S3

**Available Environments:**
- `dev` - Development
- `test` - Testing
- `prod` - Production

### Step 2: Review Changes
```bash
terraform plan
```

**What to Look For:**
- ✅ Bedrock Agent creation
- ✅ Lambda functions (2 total: traditional + agentcore)
- ✅ API Gateway routes
- ✅ IAM roles and policies
- ❌ No OpenSearch Serverless (cost optimization)
- ❌ No Knowledge Base (cost optimization)

### Step 3: Deploy
```bash
terraform apply
```

**Type:** `yes` when prompted

**Deployment Time:** ~5-10 minutes

### Step 4: Get Outputs
```bash
terraform output
```

**Save These Values:**
- `agentcore_agent_id` - Your Bedrock Agent ID
- `agentcore_agent_alias_id` - Agent alias ID
- `agentcore_api_endpoint` - API endpoint for Agentcore
- `api_gateway_url` - Traditional backend endpoint

### Step 5: Test Both Backends

**Traditional Backend:**
```bash
API_URL=$(terraform output -raw api_gateway_url)
curl -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello! Tell me about yourself."}'
```

**Agentcore Backend:**
```bash
AGENTCORE_URL=$(terraform output -raw agentcore_api_endpoint)
curl -X POST "$AGENTCORE_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello! Tell me about yourself."}'
```

## 🔍 Verification

### Check Agent Status
```bash
AGENT_ID=$(terraform output -raw agentcore_agent_id)
aws bedrock-agent get-agent --agent-id "$AGENT_ID"
```

**Expected Status:** `PREPARED` or `READY`

### Check Lambda Functions
```bash
aws lambda list-functions --query 'Functions[?contains(FunctionName, `twin`)].FunctionName'
```

**Expected Output:**
- `twin-{env}-api` (traditional)
- `twin-{env}-agentcore-api` (agentcore)

### Check API Gateway
```bash
aws apigatewayv2 get-apis --query 'Items[?contains(Name, `twin`)].Name'
```

## 🐛 Troubleshooting

### Error: "Agent not found"
**Solution:** Wait 1-2 minutes after deployment, then test again.

### Error: "Access denied to Bedrock"
**Solution:** Check IAM permissions for Bedrock and Bedrock Agents.

### Error: "Context files not found"
**Solution:** Ensure `backend/data/` files exist before running `terraform apply`.

### Error: "Provider not found"
**Solution:** Run `terraform init` first.

## 📊 Post-Deployment

### Monitor Logs
```bash
# Traditional backend
aws logs tail /aws/lambda/twin-{env}-api --follow

# Agentcore backend
aws logs tail /aws/lambda/twin-{env}-agentcore-api --follow
```

### Update Context
When you update `backend/data/` files:
```bash
cd terraform
terraform apply
```

Terraform will detect changes and update the agent instructions.

## 💰 Cost Monitoring

### Check Current Costs
```bash
# View Lambda invocations
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=twin-{env}-agentcore-api \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 86400 \
  --statistics Sum
```

### Expected Monthly Costs
- Lambda: ~$1-5
- Bedrock API calls: ~$3-10
- API Gateway: ~$1-5
- **Total: ~$5-20/month** (usage-based)

## ✅ Success Criteria

- [ ] Both backends respond to test requests
- [ ] Agent status is PREPARED or READY
- [ ] Lambda functions are deployed
- [ ] API Gateway routes are configured
- [ ] No OpenSearch Serverless costs
- [ ] Context is embedded in agent instructions

## 🎉 Next Steps

1. Update frontend to use new endpoints (optional)
2. Test with real users
3. Compare Traditional vs Agentcore performance
4. Choose which backend to use in production
5. Review `BACKEND_COMPARISON.md` for decision guidance

## 📚 Additional Resources

- **Troubleshooting**: `AGENTCORE_MIGRATION_GUIDE.md`
- **Cost Details**: `AGENTCORE_COST_OPTIMIZED.md`
- **Feature Comparison**: `BACKEND_COMPARISON.md`
- **AWS Documentation**: https://aws.amazon.com/bedrock/agentcore/

---

**Last Updated:** December 2025  
**Version:** 0.2.0
