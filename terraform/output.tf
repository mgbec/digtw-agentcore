output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "cloudfront_url" {
  description = "URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "s3_frontend_bucket" {
  description = "Name of the S3 bucket for frontend"
  value       = aws_s3_bucket.frontend.id
}

output "s3_memory_bucket" {
  description = "Name of the S3 bucket for memory storage"
  value       = aws_s3_bucket.memory.id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "custom_domain_url" {
  description = "Root URL of the production site"
  value       = var.use_custom_domain ? "https://${var.root_domain}" : ""
}
# Agentco
re Outputs
output "agentcore_agent_id" {
  description = "Bedrock Agentcore Agent ID"
  value       = aws_bedrockagent_agent.digital_twin.agent_id
}

output "agentcore_agent_alias_id" {
  description = "Bedrock Agentcore Agent Alias ID"
  value       = aws_bedrockagent_agent_alias.digital_twin_prod.agent_alias_id
}

output "agentcore_api_endpoint" {
  description = "API Gateway endpoint for Agentcore backend"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/agentcore"
}

# Note: No Knowledge Base used to avoid OpenSearch Serverless costs
# Context is embedded directly in agent instructions
