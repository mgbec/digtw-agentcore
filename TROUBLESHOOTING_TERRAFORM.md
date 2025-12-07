# Terraform Troubleshooting Guide

## Common Errors and Solutions

### Option 1: Deploy Traditional Backend Only (Recommended to Start)

If you're getting errors with Agentcore, the easiest solution is to deploy the traditional backend first:

```bash
cd terraform

# Temporarily disable Agentcore
mv agentcore.tf agentcore.tf.disabled
mv agentcore_variables.tf agentcore_variables.tf.disabled

# Deploy traditional backend only
./init.sh dev
terraform apply
```

**Benefits:**
- ✅ Proven, stable technology
- ✅ No Bedrock Agents API dependencies
- ✅ Works in all regions
- ✅ Faster deployment
- ✅ Same cost as Agentcore

You can always add Agentcore later when you're ready!

---

### Option 2: Fix Agentcore Errors

If you want to troubleshoot Agentcore, please share the specific errors. Common issues:

#### Error: "Resource type not found"
**Cause:** AWS provider doesn't support Bedrock Agents yet  
**Solution:** Update AWS provider or use Option 1

```hcl
# In versions.tf, try:
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.30"  # or latest
  }
}
```

#### Error: "Bedrock Agents not available"
**Cause:** Your AWS account/region doesn't have Bedrock Agents enabled  
**Solution:** 
1. Check AWS Console → Bedrock → Agents
2. Request access if needed
3. Or use Option 1 (traditional backend)

#### Error: "Circular dependency"
**Cause:** Action group references Lambda  
**Solution:** Remove action group resource (not needed for basic agent)

#### Error: "Invalid agent configuration"
**Cause:** Agent instructions too long or invalid format  
**Solution:** Simplify context in backend/data/ files

---

## Quick Diagnosis

### Check AWS Provider Version
```bash
cd terraform
terraform version
```

**Need:** AWS provider >= 5.30 for Bedrock Agents

### Check Bedrock Access
```bash
aws bedrock list-foundation-models --region us-east-1
```

**Should return:** List of models (confirms Bedrock access)

### Check Bedrock Agents Access
```bash
aws bedrock-agent list-agents --region us-east-1 2>&1
```

**If error:** Bedrock Agents not available in your account/region

---

## Recommended Deployment Path

### Phase 1: Traditional Backend (Start Here)
```bash
cd terraform
mv agentcore.tf agentcore.tf.disabled
mv agentcore_variables.tf agentcore_variables.tf.disabled
./init.sh dev
terraform apply
```

**Result:** Working digital twin with traditional backend

### Phase 2: Test Traditional Backend
```bash
API_URL=$(cd terraform && terraform output -raw api_gateway_url)
curl -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}'
```

**Result:** Verify everything works

### Phase 3: Add Agentcore (Optional, Later)
```bash
cd terraform
mv agentcore.tf.disabled agentcore.tf
mv agentcore_variables.tf.disabled agentcore_variables.tf
terraform apply
```

**Result:** Both backends running

---

## Error Reporting

If you need help, please provide:

1. **Terraform version:**
   ```bash
   terraform version
   ```

2. **AWS provider version:**
   ```bash
   grep -A 3 'required_providers' terraform/versions.tf
   ```

3. **Full error message:**
   ```bash
   terraform apply 2>&1 | tee error.log
   ```

4. **AWS region:**
   ```bash
   echo $AWS_REGION
   aws configure get region
   ```

5. **Bedrock access:**
   ```bash
   aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[0]'
   ```

---

## Why Traditional Backend is Great

Don't feel like you're missing out! The traditional backend:

✅ **Same features** - Chat, memory, context
✅ **Same cost** - ~$5-20/month
✅ **More control** - Full code access
✅ **Easier debugging** - Standard Python
✅ **Proven technology** - FastAPI + Bedrock
✅ **Works everywhere** - No special API access needed

Agentcore is nice for:
- Multi-agent orchestration (future)
- Built-in memory (convenience)
- AWS-native management (preference)

But for a single digital twin chatbot, traditional backend is perfect!

---

## Quick Fix Commands

### Deploy Traditional Only
```bash
cd terraform
mv agentcore.tf agentcore.tf.disabled 2>/dev/null || true
mv agentcore_variables.tf agentcore_variables.tf.disabled 2>/dev/null || true
./init.sh dev
terraform apply
```

### Re-enable Agentcore
```bash
cd terraform
mv agentcore.tf.disabled agentcore.tf 2>/dev/null || true
mv agentcore_variables.tf.disabled agentcore_variables.tf 2>/dev/null || true
terraform apply
```

### Clean Start
```bash
cd terraform
rm -rf .terraform .terraform.lock.hcl
./init.sh dev
terraform apply
```

---

## Support

1. Check this guide first
2. Review `DEPLOYMENT_CHECKLIST.md`
3. Try traditional backend only (Option 1)
4. Share specific errors for help

**Remember:** Traditional backend is production-ready and works great! 🎉
