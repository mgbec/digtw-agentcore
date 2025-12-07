"""
AWS Bedrock Agentcore Implementation
This runs alongside the existing FastAPI server as an alternative backend.
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from typing import Optional, List, Dict
import json
import uuid
from datetime import datetime
import boto3
from botocore.exceptions import ClientError
from resources import linkedin, summary, facts, style

# Load environment variables
load_dotenv()

app = FastAPI(title="Digital Twin - Agentcore Edition")

# Configure CORS
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# Initialize AWS clients
bedrock_agent_runtime = boto3.client(
    service_name="bedrock-agent-runtime",
    region_name=os.getenv("DEFAULT_AWS_REGION", "us-east-1")
)

# Agentcore configuration
AGENT_ID = os.getenv("AGENTCORE_AGENT_ID", "")
AGENT_ALIAS_ID = os.getenv("AGENTCORE_AGENT_ALIAS_ID", "TSTALIASID")  # Test alias
ENABLE_TRACE = os.getenv("AGENTCORE_ENABLE_TRACE", "true").lower() == "true"


# Request/Response models
class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None


class ChatResponse(BaseModel):
    response: str
    session_id: str
    agent_type: str = "agentcore"
    trace: Optional[Dict] = None


def invoke_agentcore_agent(user_message: str, session_id: str) -> Dict:
    """
    Invoke the Bedrock Agentcore agent with conversation memory.
    Agentcore handles memory automatically via session_id.
    """
    try:
        response = bedrock_agent_runtime.invoke_agent(
            agentId=AGENT_ID,
            agentAliasId=AGENT_ALIAS_ID,
            sessionId=session_id,
            inputText=user_message,
            enableTrace=ENABLE_TRACE,
        )
        
        # Process the streaming response
        agent_response = ""
        trace_data = []
        
        for event in response.get("completion", []):
            if "chunk" in event:
                chunk = event["chunk"]
                if "bytes" in chunk:
                    agent_response += chunk["bytes"].decode("utf-8")
            
            # Capture trace information if enabled
            if ENABLE_TRACE and "trace" in event:
                trace_data.append(event["trace"])
        
        return {
            "response": agent_response,
            "trace": trace_data if ENABLE_TRACE else None
        }
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'ResourceNotFoundException':
            raise HTTPException(
                status_code=404, 
                detail=f"Agentcore agent not found. Please deploy the agent first. Agent ID: {AGENT_ID}"
            )
        elif error_code == 'AccessDeniedException':
            raise HTTPException(
                status_code=403, 
                detail="Access denied to Bedrock Agentcore. Check IAM permissions."
            )
        else:
            raise HTTPException(
                status_code=500, 
                detail=f"Agentcore error: {str(e)}"
            )


@app.get("/")
async def root():
    return {
        "message": "AI Digital Twin API (Powered by AWS Bedrock Agentcore)",
        "version": "agentcore",
        "agent_id": AGENT_ID if AGENT_ID else "NOT_CONFIGURED",
        "memory": "Built-in Agentcore Memory Service",
        "features": [
            "Multi-agent orchestration",
            "Automatic conversation memory",
            "Agent collaboration",
            "Built-in tracing"
        ]
    }


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "backend": "agentcore",
        "agent_configured": bool(AGENT_ID),
        "trace_enabled": ENABLE_TRACE
    }


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Chat endpoint using Bedrock Agentcore.
    Memory is handled automatically by Agentcore's session management.
    """
    if not AGENT_ID:
        raise HTTPException(
            status_code=503,
            detail="Agentcore agent not configured. Set AGENTCORE_AGENT_ID environment variable."
        )
    
    try:
        # Generate session ID if not provided
        session_id = request.session_id or str(uuid.uuid4())

        # Invoke Agentcore agent (memory is automatic)
        result = invoke_agentcore_agent(request.message, session_id)

        return ChatResponse(
            response=result["response"],
            session_id=session_id,
            agent_type="agentcore",
            trace=result.get("trace") if ENABLE_TRACE else None
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in Agentcore chat endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/agent/info")
async def agent_info():
    """Get information about the configured Agentcore agent"""
    if not AGENT_ID:
        return {
            "configured": False,
            "message": "Agent not configured. Deploy using Terraform first."
        }
    
    try:
        # Get agent details
        bedrock_agent = boto3.client(
            service_name="bedrock-agent",
            region_name=os.getenv("DEFAULT_AWS_REGION", "us-east-1")
        )
        
        agent_details = bedrock_agent.get_agent(agentId=AGENT_ID)
        
        return {
            "configured": True,
            "agent_id": AGENT_ID,
            "agent_name": agent_details["agent"]["agentName"],
            "agent_status": agent_details["agent"]["agentStatus"],
            "foundation_model": agent_details["agent"].get("foundationModel", "N/A"),
        }
    except Exception as e:
        return {
            "configured": True,
            "agent_id": AGENT_ID,
            "error": str(e)
        }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)  # Different port from original
