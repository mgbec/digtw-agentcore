"""
Lambda handler for Agentcore backend
"""
from mangum import Mangum
from agentcore_server import app

# Create the Lambda handler
handler = Mangum(app)
