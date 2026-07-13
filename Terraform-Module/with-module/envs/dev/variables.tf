variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID — find with: aws ec2 describe-vpcs --filters Name=isDefault,Values=true"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID inside the VPC"
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI for your region"
  type        = string
}
