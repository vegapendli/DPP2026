# ============================================================
# modules/ec2/outputs.tf
# ------------------------------------------------------------
# These are the RETURN VALUES of the module.
# Callers access them as: module.<name>.<output>
# e.g.  module.dev_web.instance_id
#       module.prod_web.public_ip
# ============================================================

output "instance_id" {
  description = "ID of the EC2 instance (e.g. i-0abc123def456789)"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "private_ip" {
  description = "Private IP address (always available even without public IP)"
  value       = aws_instance.web.private_ip
}

output "security_group_id" {
  description = "ID of the web security group — pass this to RDS, ALB, etc."
  value       = aws_security_group.web.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.web.arn
}
