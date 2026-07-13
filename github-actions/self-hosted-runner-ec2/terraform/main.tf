data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "runner" {
  name        = "gha-self-hosted-runner"
  description = "Self-hosted GitHub Actions runner - outbound only by default"

  egress {
    description = "All outbound (runner long-polls GitHub over HTTPS)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.ssh_cidr != "" ? [var.ssh_cidr] : []
    content {
      description = "SSH for debugging"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  tags = {
    Name = "gha-self-hosted-runner"
  }
}

resource "aws_instance" "runner" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.runner.id]
  iam_instance_profile   = var.iam_instance_profile

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    github_repo_url = var.github_repo_url
    runner_token    = var.runner_registration_token
    runner_name     = var.runner_name
  })

  tags = {
    Name = "gha-self-hosted-runner"
  }
}
