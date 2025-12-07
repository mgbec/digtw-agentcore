terraform {
  backend "s3" {
    # Backend configuration
    # Initialize with: terraform init -backend-config=backend-dev.tfbackend
    # Or set these values directly:
    # bucket = "twin-terraform-state-339712707840"
    # key    = "dev/terraform.tfstate"
    # region = "us-east-1"
  }
}