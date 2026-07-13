# ============================================================
# WITHOUT MODULE — QA Environment
# ------------------------------------------------------------
# COPY-PASTE #2 of dev/main.tf.
# Differences: name tags say "qa", instance_type = t3.small
# Everything else is IDENTICAL to dev/main.tf.
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
# IDENTICAL ingress/egress rules as dev — copy-pasted.
resource "aws_security_group" "web" {
  name        = "qa-web-sg"
  description = "Allow HTTP inbound for qa web server"
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
    Name    = "qa-web-sg"
    Env     = "qa"
    Project = "zen-pharma"
  }
}

# ── EC2 Instance ───────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.small"   # only difference from dev
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name    = "qa-web-server"
    Env     = "qa"
    Project = "zen-pharma"
  }
}

output "instance_id"       { value = aws_instance.web.id }
output "public_ip"         { value = aws_instance.web.public_ip }
output "security_group_id" { value = aws_security_group.web.id }
