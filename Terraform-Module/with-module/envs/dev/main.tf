# ============================================================
# with-module/envs/dev/main.tf
# ------------------------------------------------------------
# Root module for the DEV environment.
# Calls modules/ec2 — passes dev-specific values.
# The actual SG + EC2 logic lives in modules/ec2/main.tf.
# ============================================================

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ── Call the module ────────────────────────────────────────
module "web" {
  source = "../../modules/ec2"   # relative path to the module

  # Required inputs
  env       = "dev"
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
  ami_id    = var.ami_id

  # Optional overrides (module defaults to t3.micro if omitted)
  instance_type = "t3.micro"
  project       = "zen-pharma"

  # Stretch: uncomment to also open port 443
  # allowed_https_cidrs = ["0.0.0.0/0"]
}

# ── Expose module outputs to the CLI ──────────────────────
output "instance_id" {
  description = "Dev EC2 instance ID"
  value       = module.web.instance_id
}

output "public_ip" {
  description = "Dev EC2 public IP — open in browser to test nginx"
  value       = module.web.public_ip
}

output "security_group_id" {
  description = "Dev SG ID"
  value       = module.web.security_group_id
}
