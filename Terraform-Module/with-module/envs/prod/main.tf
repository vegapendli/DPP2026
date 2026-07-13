# ============================================================
# with-module/envs/prod/main.tf
# ------------------------------------------------------------
# Root module for PROD — SAME module call as dev & qa.
# instance_type = t3.medium.
# also opens port 443 via allowed_https_cidrs (stretch demo).
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

module "web" {
  source = "../../modules/ec2"

  env           = "prod"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_id        = var.ami_id
  instance_type = "t3.medium"   # bigger instance for prod
  project       = "zen-pharma"

  # Prod opens HTTPS as well — module handles this via dynamic block
  # Without a module you'd need to add the ingress block manually in all 3 files
  allowed_https_cidrs = ["0.0.0.0/0"]
}

output "instance_id"       { value = module.web.instance_id }
output "public_ip"         { value = module.web.public_ip }
output "security_group_id" { value = module.web.security_group_id }
