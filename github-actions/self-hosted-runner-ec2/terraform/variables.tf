variable "aws_region" {
  description = "AWS region to deploy the runner in"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the runner"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair, for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the runner into. Leave null to use the default VPC's default subnet"
  type        = string
  default     = null
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH into the runner, e.g. \"1.2.3.4/32\". Leave empty to disable inbound SSH entirely (runner only needs outbound)"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "Optional IAM instance profile name to attach, if your jobs need to call AWS APIs (e.g. deploy to S3/ECS)"
  type        = string
  default     = null
}

variable "github_repo_url" {
  description = "Full URL of the GitHub repo the runner registers against, e.g. https://github.com/owner/repo"
  type        = string
}

variable "runner_registration_token" {
  description = "Short-lived registration token from Settings -> Actions -> Runners -> New self-hosted runner. Expires in ~1 hour, so apply shortly after generating it."
  type        = string
  sensitive   = true
}

variable "runner_name" {
  description = "Name the runner registers under in GitHub"
  type        = string
  default     = "gha-ec2-runner"
}
