# ============================================================
# WITHOUT MODULE — Prod Environment
# ------------------------------------------------------------
# COPY-PASTE #3.  instance_type = t3.medium.
# Still the exact same SG block for the third time.
# If a security audit requires port 443 to be added,
# an engineer must edit all 3 files and hope they don't
# miss one — or introduce a typo in prod.
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

variable "aws_region" { default = "us-east-1" }
variable "vpc_id"     { description = "VPC ID to deploy into" }
variable "subnet_id"  { description = "Subnet ID for the EC2 instance" }
variable "ami_id"     { description = "AMI ID" }

# ── Security Group ─────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "prod-web-sg"
  description = "Allow HTTP inbound for prod web server"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "prod-web-sg"
    Env     = "prod"
    Project = "zen-pharma"
  }
}

# ── EC2 Instance ───────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.medium"  # only difference from dev/qa
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name    = "prod-web-server"
    Env     = "prod"
    Project = "zen-pharma"
  }
}

output "instance_id"       { value = aws_instance.web.id }
output "public_ip"         { value = aws_instance.web.public_ip }
output "security_group_id" { value = aws_security_group.web.id }
