# ============================================================
# WITHOUT MODULE — Dev Environment
# ------------------------------------------------------------
# Notice: aws_security_group + aws_instance are written here
# IN FULL.  The same block is copy-pasted into qa/ and prod/.
# This is the PROBLEM we are solving with modules.
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

# ── Variables ─────────────────────────────────────────────
variable "aws_region"    { default = "us-east-1" }
variable "vpc_id"        { description = "VPC ID to deploy into" }
variable "subnet_id"     { description = "Subnet ID for the EC2 instance" }
variable "ami_id"        { description = "AMI ID (use Amazon Linux 2 for your region)" }

# ── Security Group ─────────────────────────────────────────
# BUG RISK: if you need to change this rule, you must
# remember to change it in qa/main.tf and prod/main.tf too.
resource "aws_security_group" "web" {
  name        = "dev-web-sg"
  description = "Allow HTTP inbound for dev web server"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
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
    Name    = "dev-web-sg"
    Env     = "dev"
    Project = "zen-pharma"
  }
}

# ── EC2 Instance ───────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"   # hardcoded — can't reuse for t3.small
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name    = "dev-web-server"
    Env     = "dev"
    Project = "zen-pharma"
  }
}

# ── Outputs ────────────────────────────────────────────────
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web.id
}
