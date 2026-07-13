# ============================================================
# modules/ec2/variables.tf
# ------------------------------------------------------------
# These are the INPUT PARAMETERS of the module.
# Think of them as function arguments.
# The caller (envs/dev, qa, prod) passes values for these.
# ============================================================

variable "env" {
  description = "Environment name (dev, qa, prod). Used in resource names and tags."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.env)
    error_message = "env must be one of: dev, qa, prod."
  }
}

variable "project" {
  description = "Project name. Used in tags."
  type        = string
  default     = "zen-pharma"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the security group into."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to launch the EC2 instance into."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance. Use Amazon Linux 2 for your region."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type. Defaults to t3.micro (free-tier eligible)."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed to reach port 80. Defaults to 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "List of CIDR blocks allowed to reach port 443. Empty = 443 not open."
  type        = list(string)
  default     = []
}
