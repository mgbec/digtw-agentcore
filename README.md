# AI Digital Twin

An AI-powered digital twin application that combines a Next.js frontend with a FastAPI backend, deployed on AWS using Terraform. The system leverages AWS Bedrock's Amazon Nova models for intelligent conversations with persistent session memory.

## 📋 Project Overview

**Digital Twin** is a full-stack application that provides an AI course companion capable of:
- Real-time chat interactions with context-aware responses
- Session-based conversation memory (stored in S3)
- Lambda-optimized backend deployment
- Responsive, modern UI with TypeScript and Tailwind CSS
- Multi-environment support (dev, test, prod)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Next.js Frontend (port 3000)               │
│         React 19.2.1 + TypeScript + Tailwind            │
└─────────────────────────────────────────────────────────┘
                            │
                    HTTP/HTTPS API
                            │
┌─────────────────────────────────────────────────────────┐
│         AWS Lambda + FastAPI Backend                    │
│  - Bedrock AI (Amazon Nova) Integration                 │
│  - Session Management                                   │
│  - CORS Configured                                      │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
    ┌───▼───┐           ┌──▼───┐          ┌───▼──┐
    │  S3   │           │Bedrock          │CloudFront
    │Memory │           │Models           │Cache
    └───────┘           └──────┘          └──────┘
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
│   ├── server.py              # Main FastAPI app
│   ├── lambda_handler.py      # AWS Lambda entry point
│   ├── context.py             # AI prompt context
│   ├── resources.py           # Shared utilities
│   ├── deploy.py              # Lambda packaging script
│   ├── requirements.txt        # Python dependencies
│   ├── data/                  # Static data files
│   │   ├── facts.json         # Knowledge base
│   │   ├── style.txt          # Response style guidelines
│   │   └── summary.txt        # System summary
│   └── lambda-package/        # Packaged Lambda deployment
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                # Resource definitions
│   ├── variables.tf           # Input variables
│   ├── versions.tf            # Provider versions
│   ├── output.tf              # Output values
│   ├── terraform.tfvars       # Environment-specific vars
│   └── terraform.tfstate.d/   # State storage backends
│
├── scripts/
│   ├── deploy.sh              # Main deployment script (Bash)
│   └── deploy.ps1             # Alternative deployment (PowerShell)
│
├── memory/                      # Local session memory (dev)
│   └── *.json                 # Session conversation history
│
└── README.md                   # This file
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
# Deploy to dev environment
./scripts/deploy.sh dev

# Deploy to production
./scripts/deploy.sh prod twin
```

**What the deployment does:**
1. ✅ Packages the backend into a Lambda-compatible ZIP
2. ✅ Initializes Terraform state in S3
3. ✅ Creates/updates AWS infrastructure:
   - Lambda function with FastAPI/Mangum
   - API Gateway for HTTP routing
   - S3 bucket for conversation memory
   - CloudFront CDN (optional)
   - IAM roles and policies
4. ✅ Deploys the frontend to CloudFront/S3
5. ✅ Outputs API endpoint and frontend URL

### Deployment Requirements
- AWS account with appropriate permissions (Lambda, API Gateway, S3, IAM, Bedrock)
- S3 backend bucket for Terraform state: `twin-terraform-state-{ACCOUNT_ID}`
- AWS Bedrock model access in your region

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

Once the backend is running, visit `http://localhost:8000/docs` for interactive API documentation (Swagger UI).

### Main Endpoint
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

## 🗂️ Conversation Memory

### Development (Local)
Conversations are stored in `memory/` directory as JSON files.

### Production (S3)
Sessions are automatically saved to S3 bucket specified in environment variables. Each session is stored with a unique ID for retrieval.

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

## 📖 Documentation Links

- [Next.js Documentation](https://nextjs.org/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [AWS Bedrock](https://aws.amazon.com/bedrock/)
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

**Last Updated:** December 2025  
**Version:** 0.1.0
