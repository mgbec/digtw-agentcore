# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2025-12-07

### Added - AWS Bedrock Agentcore Support 🎉

#### New Backend Implementation
- **Agentcore FastAPI server** (`backend/agentcore_server.py`)
  - Parallel deployment alongside traditional backend
  - Endpoint: `/agentcore/chat`, `/agentcore/health`
  - Built-in conversation memory via Bedrock Agent
  - Optional trace data for debugging

- **Agent Configuration** (`backend/agentcore_config.py`)
  - Supervisor agent instructions
  - Digital twin agent instructions
  - Programmatic agent configuration

- **Lambda Handler** (`backend/agentcore_lambda_handler.py`)
  - Separate Lambda function for Agentcore
  - Mangum adapter for ASGI support

#### Infrastructure
- **Terraform Resources** (`terraform/agentcore.tf`)
  - Bedrock Agent with embedded context
  - IAM roles and policies for agent execution
  - API Gateway routes for `/agentcore/*` endpoints
  - Lambda function for Agentcore backend
  - Cost-optimized: No Knowledge Base (saves ~$175/month)

- **Variables** (`terraform/agentcore_variables.tf`)
  - `agentcore_foundation_model` - Model selection for agents
  - `enable_agentcore` - Toggle Agentcore deployment

- **Outputs** (`terraform/output.tf`)
  - `agentcore_agent_id` - Bedrock Agent ID
  - `agentcore_agent_alias_id` - Agent alias for stable endpoint
  - `agentcore_api_endpoint` - API Gateway endpoint

#### Documentation
- **Quick Start Guide** (`QUICK_START_AGENTCORE.md`)
  - 3-step deployment process
  - Cost comparison
  - Testing instructions

- **Migration Guide** (`AGENTCORE_MIGRATION_GUIDE.md`)
  - Detailed architecture comparison
  - Step-by-step deployment
  - Troubleshooting section
  - Migration strategies

- **Cost Optimization** (`AGENTCORE_COST_OPTIMIZED.md`)
  - Detailed cost breakdown
  - Embedded context vs Knowledge Base
  - When to use each approach
  - Future scaling options

#### Scripts
- **Agent Preparation** (`scripts/upload_knowledge_base.sh`)
  - Prepare Bedrock Agent for deployment
  - No upload needed (context embedded)

#### Configuration
- **Environment Template** (`backend/.env.agentcore`)
  - Agentcore-specific environment variables
  - Agent ID and alias configuration
  - Trace enablement

### Changed
- **README.md** - Updated with Agentcore information
  - Dual backend architecture diagram
  - Backend comparison table
  - Choosing between backends guide
  - Updated project structure
  - New troubleshooting sections

- **Project Structure** - Added Agentcore files to directory tree

### Technical Details

#### Cost Optimization
- **Removed**: OpenSearch Serverless (~$175/month)
- **Removed**: Knowledge Base infrastructure
- **Added**: Embedded context in agent instructions (FREE)
- **Result**: Same cost as traditional backend (~$5-20/month)

#### Context Management
- Context loaded from `backend/data/` files during Terraform deployment
- Facts, style, and summary embedded directly in agent instructions
- Updates require `terraform apply` to refresh agent

#### Deployment Strategy
- Both backends deployed simultaneously
- Independent Lambda functions
- Separate API Gateway routes
- No impact on existing traditional backend

## [0.1.0] - 2025-12-01

### Added - Initial Release
- Next.js frontend with TypeScript and Tailwind CSS
- FastAPI backend with AWS Bedrock integration
- Terraform infrastructure as code
- Lambda deployment with Mangum adapter
- S3-based conversation memory
- CloudFront CDN distribution
- Multi-environment support (dev, test, prod)
- Security patches for CVE-2025-55182

---

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality (backwards compatible)
- **PATCH** version for backwards compatible bug fixes
