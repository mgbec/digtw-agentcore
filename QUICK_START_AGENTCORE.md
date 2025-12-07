# Agentcore Quick Start

## 🚀 Deploy in 3 Steps

### 1. Deploy Infrastructure
```bash
cd terraform
terraform apply
```

### 2. Get Your Endpoints
```bash
terraform output agentcore_api_endpoint
terraform output agentcore_agent_id
```

### 3. Test It
```bash
# Original backend (still works)
curl -X POST https://your-api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hi!"}'

# New Agentcore backend
curl -X POST https://your-api/agentcore/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hi!"}'
```

## 📊 What You Get

✅ **Two backends running in parallel**
- Original: `/chat` (unchanged)
- Agentcore: `/agentcore/chat` (new)

✅ **Cost-optimized**
- No Knowledge Base = No OpenSearch Serverless costs
- Context embedded in agent instructions
- Only pay for API calls

✅ **Better features**
- Automatic conversation memory
- Built-in tracing
- Multi-agent orchestration ready
- Better session management

## 🔄 Update Context

Edit your files:
```bash
vim backend/data/facts.json
vim backend/data/style.txt
vim backend/data/summary.txt
```

Redeploy:
```bash
cd terraform
terraform apply
```

## 💰 Cost

**Original backend**: ~$5-20/month (usage-based)
**Agentcore backend**: ~$5-20/month (usage-based)

No additional infrastructure costs!

## 📚 More Info

- Full guide: `AGENTCORE_MIGRATION_GUIDE.md`
- Cost details: `AGENTCORE_COST_OPTIMIZED.md`
