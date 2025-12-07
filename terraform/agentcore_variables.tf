# Additional variables for Agentcore deployment

variable "agentcore_foundation_model" {
  description = "Foundation model for Agentcore agents"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "enable_agentcore" {
  description = "Enable Agentcore deployment alongside existing backend"
  type        = bool
  default     = true
}
