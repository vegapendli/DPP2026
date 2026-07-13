output "instance_id" {
  value = aws_instance.runner.id
}

output "instance_public_ip" {
  value = aws_instance.runner.public_ip
}

output "ssh_command" {
  description = "How to SSH in for debugging (only works if ssh_cidr was set)"
  value       = var.ssh_cidr != "" ? "ssh -i <path-to-${var.key_name}.pem> ubuntu@${aws_instance.runner.public_ip}" : "SSH disabled (ssh_cidr not set)"
}
