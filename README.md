# AI Digital Twin

An AI-powered digital twin application that combines a Next.js frontend with a FastAPI backend, deployed on AWS using Terraform. The system leverages AWS Bedrock's Amazon Nova models for intelligent conversations with persistent session memory.

## 📋 Project Overview

**Digital Twin** is a full-stack application that provides an AI course companion capable of:
- Real-time chat interactions with context-aware responses
- Session-based conversation memory (stored in S3)
- Lambda-optimized backend deployment
- **Dual backend support**: Traditional FastAPI + AWS Bedrock Agentcore
- Responsive, modern UI with TypeScript and Tailwind CSS
- Multi-environment support (dev, test, prod)

## 🏗️ Architecture

### Dual Backend Architecture

This project supports **two backend implementations** running in parallel:

**1. Traditional Backend** (`/chat` endpoint)
```
Frontend → API Gateway → Lambda (FastAPI)
                           ↓
                    Direct Bedrock API
                           ↓
                    Manual S3 Memory
```

**2. Agentcore Backend** (`/agentcore/chat` endpoint) - NEW! 🎉
```
Frontend → API Gateway → Lambda (FastAPI)
                           ↓
                    Bedrock Agent
                           ↓
                    Built-in Memory Service
```

### Full Architecture Diagram
```
┌─────────────────────────────────────────────────────────┐
│              Next.js Frontend (port 3000)               │
│         React 19.2.1 + TypeScript + Tailwind            │
└─────────────────────────────────────────────────────────┘
                            │
                    HTTP/HTTPS API
                            │
                ┌───────────┴───────────┐
                │                       │
        ┌───────▼────────┐    ┌────────▼─────────┐
        │ Traditional    │    │   Agentcore      │
        │ Lambda Backend │    │  Lambda Backend  │
        │   (/chat)      │    │ (/agentcore/*)   │
        └───────┬────────┘    └────────┬─────────┘
                │                      │
        ┌───────▼────────┐    ┌────────▼─────────┐
        │ Direct Bedrock │    │  Bedrock Agent   │
        │   API Calls    │    │  Orchestration   │
        └───────┬────────┘    └────────┬─────────┘
                │                      │
        ┌───────▼────────┐    ┌────────▼─────────┐
        │  S3 Memory     │    │  Built-in Memory │
        │  (Manual)      │    │   (Automatic)    │
        └────────────────┘    └──────────────────┘
                │                      │
                └──────────┬───────────┘
                           │
                    ┌──────▼──────┐
                    │  CloudFront │
                    │    Cache    │
                    └─────────────┘
```

## 📁 Project Structure

```
twin/
├── frontend/                    # Next.js React application
│   ├── app/                    # App Router pages
│   │   ├── layout.tsx         # Root layout
│   │   ├── page.tsx           # Home page
│   │   └── globals.css        # Global styles
│   ├── components/
│   │   └── twin.tsx           # Main chat component
│   ├── public/                # Static assets
│   ├── package.json           # Dependencies
│   └── next.config.ts         # Next.js configuration
│
├── backend/                     # FastAPI Python backend
│   ├── server.py              # Traditional FastAPI app
│   ├── lambda_handler.py      # Traditional Lambda entry point
│   ├── agentcore_server.py    # Agentcore FastAPI app (NEW)
│   ├── agentcore_lambda_handler.py  # Agentcore Lambda entry point (NEW)
│   ├── agentcore_config.py    # Agent configuration (NEW)
│   ├── context.py             # AI prompt context
│   ├── resources.py           # Shared utilities
│   ├── deploy.py              # Lambda packaging script
│   ├── requirements.txt        # Python dependencies
│   ├── .env.agentcore         # Agentcore environment template (NEW)
│   ├── data/                  # Static data files
│   │   ├── facts.json         # Knowledge base
│   │   ├── style.txt          # Response style guidelines
│   │   └── summary.txt        # System summary
│   └── lambda-package/        # Packaged Lambda deployment
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                # Traditional backend resources
│   ├── agentcore.tf           # Agentcore backend resources (NEW)
│   ├── agentcore_variables.tf # Agentcore variables (NEW)
│   ├── variables.tf           # Input variables
│   ├── versions.tf            # Provider versions
│   ├── output.tf              # Output values
│   ├── terraform.tfvars       # Environment-specific vars
│   └── terraform.tfstate.d/   # State storage backends
│
├── scripts/
│   ├── deploy.sh              # Main deployment script (Bash)
│   ├── deploy.ps1             # Alternative deployment (PowerShell)
│   └── upload_knowledge_base.sh  # Prepare Agentcore agent (NEW)
│
├── memory/                      # Local session memory (dev)
│   └── *.json                 # Session conversation history
│
├── README.md                      # This file (start here!)
├── DOCUMENTATION_INDEX.md         # Complete documentation guide (NEW)
├── DECISION_TREE.md               # Choose the right backend (NEW)
├── BACKEND_COMPARISON.md          # Compare Traditional vs Agentcore (NEW)
├── QUICK_START_AGENTCORE.md      # Deploy Agentcore in 3 steps (NEW)
├── AGENTCORE_MIGRATION_GUIDE.md  # Detailed deployment guide (NEW)
├── AGENTCORE_COST_OPTIMIZED.md   # Cost breakdown & optimization (NEW)
└── CHANGELOG.md                   # Version history (NEW)
```

## 🚀 Quick Start

### Prerequisites
- **Node.js** 18+ (frontend)
- **Python** 3.13+ (backend)
- **AWS CLI** configured with credentials
- **Docker** (for Lambda package building)
- **Terraform** 1.0+ (for infrastructure)
- **uv** (Python package manager, recommended)

### Local Development

#### 1. Frontend Setup
```bash
cd frontend
npm install
npm run dev
```
Visit `http://localhost:3000` to view the application.

#### 2. Backend Setup
```bash
cd backend

# Create a .env file
cat > .env << EOF
CORS_ORIGINS=http://localhost:3000
BEDROCK_MODEL_ID=amazon.nova-lite-v1:0
DEFAULT_AWS_REGION=us-east-1
USE_S3=false
MEMORY_DIR=../memory
EOF

# Install dependencies
pip install -r requirements.txt
# or with uv:
uv sync

# Run development server
uvicorn server:app --reload --port 8000
```
The API will be available at `http://localhost:8000`.

#### 3. Test the Integration
Open the frontend, type a message in the chat, and watch it communicate with your local backend.

## 🛠️ Configuration

### Environment Variables

**Frontend** (`frontend/.env.local`):
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Backend** (`backend/.env`):
```env
# AWS Configuration
DEFAULT_AWS_REGION=us-east-1
BEDROCK_MODEL_ID=amazon.nova-lite-v1:0

# CORS
CORS_ORIGINS=http://localhost:3000,https://yourdomain.com

# Storage
USE_S3=false                    # Set to true for production
S3_BUCKET=twin-memory-bucket
MEMORY_DIR=../memory           # Local path for dev

# Bedrock Model Options (pick one):
# amazon.nova-micro-v1:0   (fastest, cheapest)
# amazon.nova-lite-v1:0    (balanced - default)
# amazon.nova-pro-v1:0     (most capable, higher cost)
```

### Terraform Variables (`terraform/terraform.tfvars`)
```hcl
project_name           = "twin"
environment            = "dev"
default_aws_region     = "us-east-1"
use_custom_domain      = false
root_domain            = ""
bedrock_model_id       = "amazon.nova-lite-v1:0"
```

## 🚢 Deployment

### Deploy to AWS

```bash
# Deploy to dev environment (includes both backends)
./scripts/deploy.sh dev

# Deploy to production
./scripts/deploy.sh prod twin
```

**What the deployment does:**
1. ✅ Packages the backend into a Lambda-compatible ZIP
2. ✅ Initializes Terraform state in S3
3. ✅ Creates/updates AWS infrastructure:
   - **Traditional Backend**: Lambda function with FastAPI/Mangum
   - **Agentcore Backend**: Lambda + Bedrock Agent (NEW)
   - API Gateway for HTTP routing (both backends)
   - S3 bucket for conversation memory
   - CloudFront CDN (optional)
   - IAM roles and policies
4. ✅ Deploys the frontend to CloudFront/S3
5. ✅ Outputs API endpoints and frontend URL

### Deployment Requirements
- AWS account with appropriate permissions (Lambda, API Gateway, S3, IAM, Bedrock, Bedrock Agents)
- S3 backend bucket for Terraform state: `twin-terraform-state-{ACCOUNT_ID}`
- AWS Bedrock model access in your region
- AWS Bedrock Agents access (for Agentcore backend)

### 🆕 Agentcore Quick Start

For detailed Agentcore deployment instructions, see:
- **Quick Start**: `QUICK_START_AGENTCORE.md`
- **Full Guide**: `AGENTCORE_MIGRATION_GUIDE.md`
- **Cost Details**: `AGENTCORE_COST_OPTIMIZED.md`

```bash
# Deploy both backends
cd terraform
terraform apply

# Both endpoints will be available:
# Traditional: https://your-api/chat
# Agentcore:   https://your-api/agentcore/chat
```

## 📦 Key Dependencies

### Frontend
- **Next.js** 16.0.7 - React framework with server-side rendering
- **React** 19.2.1 - UI library
- **Tailwind CSS** 4 - Utility-first CSS framework
- **Lucide React** - Icon library
- **TypeScript** 5 - Type-safe JavaScript

### Backend
- **FastAPI** - Modern Python web framework
- **Uvicorn** - ASGI server
- **Boto3** - AWS SDK for Python
- **Mangum** - ASGI-to-Lambda adapter
- **PyPDF** - PDF processing (if needed)
- **Python Multipart** - Multipart form data handling

## 🔐 Security Considerations

### CVE-2025-55182 Mitigation ✓
This project has been patched against the critical React Server Components RCE vulnerability:
- Next.js: **16.0.7** (patched from 16.0.3)
- React: **19.2.1** (patched from 19.2.0)
- React-DOM: **19.2.1** (patched from 19.2.0)

### Best Practices
- ✅ CORS configured for specific origins
- ✅ S3 buckets with public access blocked
- ✅ IAM roles with least-privilege permissions
- ✅ Environment variables for sensitive configuration
- ✅ Session IDs validated on each request

## 🧪 Testing

### Frontend Tests
```bash
cd frontend
npm run lint
```

### Backend Tests
```bash
cd backend
# (Add pytest tests as needed)
pytest tests/
```

## 📚 API Documentation

Once the backend is running, visit the interactive API documentation (Swagger UI):
- Traditional backend: `http://localhost:8000/docs`
- Agentcore backend: `http://localhost:8001/docs`

### Traditional Backend Endpoint
**POST `/chat`**
- **Request:**
  ```json
  {
    "message": "Tell me about AI",
    "session_id": "optional-session-uuid"
  }
  ```
- **Response:**
  ```json
  {
    "response": "AI is...",
    "session_id": "generated-or-provided-uuid"
  }
  ```

### Agentcore Backend Endpoint
**POST `/agentcore/chat`**
- **Request:**
  ```json
  {
    "message": "Tell me about AI",
    "session_id": "optional-session-uuid"
  }
  ```
- **Response:**
  ```json
  {
    "response": "AI is...",
    "session_id": "generated-or-provided-uuid",
    "agent_type": "agentcore",
    "trace": {...}  // Optional trace data
  }
  ```

### Backend Comparison

| Feature | Traditional (`/chat`) | Agentcore (`/agentcore/chat`) |
|---------|----------------------|-------------------------------|
| **Memory** | Manual S3 management | Automatic (built-in) |
| **Context** | Loaded at runtime | Embedded in agent |
| **Orchestration** | Single API call | Multi-agent capable |
| **Tracing** | Manual logging | Built-in trace data |
| **Cost** | ~$5-20/month | ~$5-20/month |

## 🗂️ Conversation Memory

### Traditional Backend
- **Development (Local)**: Conversations stored in `memory/` directory as JSON files
- **Production (S3)**: Sessions saved to S3 bucket (manual management)

### Agentcore Backend
- **All Environments**: Built-in Bedrock Agent memory service (automatic)
- No manual S3 management required
- Session persistence handled by AWS

## 🎯 Choosing Between Backends

Both backends are deployed and available. Choose based on your needs:

### Use Traditional Backend (`/chat`) When:
- ✅ You want proven, stable technology
- ✅ You need full control over the conversation flow
- ✅ You're comfortable with manual memory management
- ✅ You want the simplest possible architecture

### Use Agentcore Backend (`/agentcore/chat`) When:
- ✅ You want built-in conversation memory
- ✅ You need multi-agent orchestration capabilities
- ✅ You want better tracing and debugging
- ✅ You're building complex agentic workflows
- ✅ You want AWS-native agent management

### Cost Comparison
Both backends have similar costs (~$5-20/month usage-based):
- **Traditional**: Lambda + Bedrock API calls + S3 storage
- **Agentcore**: Lambda + Bedrock Agent + Bedrock API calls

**Note**: We use embedded context instead of Knowledge Bases to avoid OpenSearch Serverless costs (~$175/month).

📊 **For detailed comparison**, see `BACKEND_COMPARISON.md`

## 🐛 Troubleshooting

### Frontend Cannot Connect to Backend
1. Check `NEXT_PUBLIC_API_URL` in frontend `.env.local`
2. Verify backend is running: `curl http://localhost:8000/docs`
3. Check CORS configuration in `backend/server.py`
4. Review browser console for exact error messages

### Lambda Deployment Fails
1. Verify Docker is running: `docker --version`
2. Check AWS credentials: `aws sts get-caller-identity`
3. Ensure Bedrock access: `aws bedrock list-foundation-models --region us-east-1`
4. Review Lambda package size (must be < 50MB for direct upload)

### Bedrock API Errors
- Model IDs may require regional prefix (e.g., `us.amazon.nova-lite-v1:0`)
- Ensure Bedrock is available in your AWS region
- Check IAM permissions for bedrock:InvokeModel

### Agentcore Agent Not Found
1. Verify Terraform deployed successfully: `cd terraform && terraform output agentcore_agent_id`
2. Check agent status in AWS Console: Bedrock > Agents
3. Ensure agent is prepared: `./scripts/upload_knowledge_base.sh dev`
4. Verify IAM permissions for bedrock:InvokeAgent

### Context Not Loading in Agentcore
1. Context is embedded during Terraform deployment from `backend/data/` files
2. If you update facts/style/summary, run `terraform apply` again
3. Check agent instructions in AWS Console to verify context is present

## 📖 Documentation Links

### Project Documentation
- **📑 Documentation Index**: `DOCUMENTATION_INDEX.md` - Complete guide to all docs
- **🌳 Decision Tree**: `DECISION_TREE.md` - Quick decision guide
- **⚖️ Backend Comparison**: `BACKEND_COMPARISON.md` - Detailed feature comparison
- **🚀 Agentcore Quick Start**: `QUICK_START_AGENTCORE.md` - Deploy in 3 steps
- **📖 Agentcore Migration Guide**: `AGENTCORE_MIGRATION_GUIDE.md` - Full deployment guide
- **💰 Cost Optimization**: `AGENTCORE_COST_OPTIMIZED.md` - Cost breakdown & savings
- **📝 Changelog**: `CHANGELOG.md` - Version history

### External Documentation
- [Next.js Documentation](https://nextjs.org/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [AWS Bedrock](https://aws.amazon.com/bedrock/)
- [AWS Bedrock Agentcore](https://aws.amazon.com/bedrock/agentcore/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes and test locally
3. Commit with clear messages: `git commit -m "Add feature X"`
4. Push and create a pull request

## 📝 License

This project is private. All rights reserved.

## 👤 Author

Created by: **mgbec**  
Repository: [digtw](https://github.com/mgbec/digtw)

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review backend logs: `aws logs tail /aws/lambda/twin-dev-backend --follow`
3. Check frontend browser console for client-side errors
4. Review GitHub Issues or contact the maintainer

---

## 🆕 What's New

### Version 0.2.0 - Agentcore Support
- ✨ Added AWS Bedrock Agentcore backend (parallel deployment)
- ✨ Dual backend architecture: Traditional + Agentcore
- ✨ Cost-optimized: No Knowledge Base (embedded context)
- ✨ Built-in conversation memory with Agentcore
- ✨ Multi-agent orchestration ready
- 📚 Comprehensive Agentcore documentation

### Version 0.1.0 - Initial Release
- 🎉 Traditional FastAPI backend with Bedrock
- 🎉 Next.js frontend with TypeScript
- 🎉 Terraform infrastructure as code
- 🎉 Multi-environment support

---

**Last Updated:** December 2025  
**Version:** 0.2.0
