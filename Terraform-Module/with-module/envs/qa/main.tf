# ============================================================
# with-module/envs/qa/main.tf
# ------------------------------------------------------------
# Root module for QA — SAME module call as dev.
# Only difference: instance_type = "t3.small"
# modules/ec2/main.tf is NOT touched or copied.
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

  env           = "qa"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ami_id        = var.ami_id
  instance_type = "t3.small"    # ← only this line differs from dev
  project       = "zen-pharma"
}

output "instance_id"       { value = module.web.instance_id }
output "public_ip"         { value = module.web.public_ip }
output "security_group_id" { value = module.web.security_group_id }
