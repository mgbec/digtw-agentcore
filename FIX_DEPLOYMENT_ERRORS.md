# Fix Deployment Errors - Step by Step

## 🎯 Quick Fix (Recommended)

Your errors are because:
1. Resources already exist from a previous deployment
2. Agent alias is being created before agent is ready

### Solution: Two-Step Deployment

```bash
cd terraform

# Step 1: Temporarily disable Agentcore (it has timing issues)
mv agentcore.tf agentcore.tf.temp
mv agentcore_variables.tf agentcore_variables.tf.temp

# Step 2: Deploy traditional backend first
terraform apply -auto-approve

# Step 3: Re-enable Agentcore
mv agentcore.tf.temp agentcore.tf
mv agentcore_variables.tf.temp agentcore_variables.tf

# Step 4: Deploy Agentcore (agent will have time to prepare)
terraform apply
```

---

## 🔧 Alternative: Import Existing Resources

If you want to keep existing resources:

```bash
cd terraform

# Import existing resources
./import-existing.sh

# Then apply
terraform apply
```

---

## 🆕 Clean Start (Nuclear Option)

If you want to start completely fresh:

```bash
# WARNING: This will destroy everything!

cd terraform

# Destroy existing resources
terraform destroy -auto-approve

# Clean state
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*

# Re-initialize
./init.sh dev

# Deploy fresh
terraform apply
```

---

## 📋 Specific Error Fixes

### Error: "Agent is in Preparing state"
**Cause:** Agent alias created too quickly  
**Fix:** Wait 2 minutes, then run `terraform apply` again

### Error: "BucketAlreadyExists"
**Cause:** S3 buckets from previous deployment  
**Fix:** Import them with `./import-existing.sh` or use different names

### Error: "Role already exists"
**Cause:** IAM role from previous deployment  
**Fix:** Import it with `./import-existing.sh`

### Error: "BucketNotEmpty" (state bucket)
**Cause:** Terraform trying to delete state bucket  
**Fix:** This shouldn't happen - state bucket should never be deleted

---

## ✅ Recommended Approach

**For your situation, I recommend:**

### Option A: Traditional Backend Only (Fastest)
```bash
cd terraform
mv agentcore.tf agentcore.tf.disabled
mv agentcore_variables.tf agentcore_variables.tf.disabled
terraform apply
```

**Result:** Working digital twin in 5 minutes

### Option B: Two-Step Deployment (Both Backends)
```bash
cd terraform

# Step 1: Traditional only
mv agentcore.tf agentcore.tf.temp
mv agentcore_variables.tf agentcore_variables.tf.temp
terraform apply

# Step 2: Add Agentcore
mv agentcore.tf.temp agentcore.tf
mv agentcore_variables.tf.temp agentcore_variables.tf
sleep 120  # Wait for agent to prepare
terraform apply
```

**Result:** Both backends working

---

## 🎯 My Recommendation

Start with **Option A** (Traditional Backend Only):

**Why?**
- ✅ Works immediately
- ✅ No timing issues
- ✅ Same features
- ✅ Same cost
- ✅ Proven technology
- ✅ You already have it partially deployed!

**Then:**
- Test it thoroughly
- Make sure everything works
- Add Agentcore later if you want it

---

## 🚀 Quick Commands

### Deploy Traditional Only
```bash
cd terraform
mv agentcore.tf agentcore.tf.disabled 2>/dev/null || true
mv agentcore_variables.tf agentcore_variables.tf.disabled 2>/dev/null || true
terraform apply -auto-approve
```

### Test It
```bash
cd terraform
API_URL=$(terraform output -raw api_gateway_url)
curl -X POST "$API_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello! Tell me about yourself."}'
```

### Add Agentcore Later
```bash
cd terraform
mv agentcore.tf.disabled agentcore.tf
mv agentcore_variables.tf.disabled agentcore_variables.tf
terraform apply
# If agent alias fails, wait 2 minutes and run again:
sleep 120 && terraform apply
```

---

## 💡 Understanding the Errors

1. **S3/IAM "Already Exists"** - You have a partial deployment
2. **Agent "Preparing state"** - Bedrock Agent takes time to prepare
3. **State bucket error** - Shouldn't happen, might be a Terraform bug

**Solution:** Deploy in stages to avoid timing issues

---

## 📞 Next Steps

1. Choose Option A or B above
2. Run the commands
3. Test your deployment
4. Enjoy your working digital twin! 🎉

**Remember:** Traditional backend is production-ready and works great!
