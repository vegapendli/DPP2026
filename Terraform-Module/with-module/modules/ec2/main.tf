# ============================================================
# modules/ec2/main.tf
# ------------------------------------------------------------
# THE SINGLE SOURCE OF TRUTH for the EC2 + SG pattern.
# This file exists ONCE. Dev, QA and Prod all share it.
# Change port 80 → 443 here = change applies everywhere.
# ============================================================

# ── Security Group ─────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "${var.env}-${var.project}-web-sg"
  description = "Allow HTTP/HTTPS inbound for ${var.env} web server"
  vpc_id      = var.vpc_id

  # Port 80 — always open (list of CIDRs is configurable)
  ingress {
    description = "HTTP from allowed CIDRs"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  # Port 443 — only created when allowed_https_cidrs is non-empty
  # Stretch challenge: pass allowed_https_cidrs = ["0.0.0.0/0"] to enable
  dynamic "ingress" {
    for_each = length(var.allowed_https_cidrs) > 0 ? [1] : []
    content {
      description = "HTTPS from allowed CIDRs"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allowed_https_cidrs
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.env}-${var.project}-web-sg"
    Env     = var.env
    Project = var.project
  }
}

# ── EC2 Instance ───────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type   # comes from caller
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  # User data: install and start nginx so you can test port 80
  user_data = <<-USERDATA
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>${var.env} web server — ${var.project}</h1>" > /usr/share/nginx/html/index.html
  USERDATA

  tags = {
    Name    = "${var.env}-${var.project}-web-server"
    Env     = var.env
    Project = var.project
  }
}
