# ── Fill in your real values ─────────────────────────────
# Find your default VPC:   aws ec2 describe-vpcs --filters Name=isDefault,Values=true
# Find a subnet:           aws ec2 describe-subnets --filters Name=vpc-id,Values=<vpc-id>
# Amazon Linux 2 AMI:      aws ec2 describe-images --owners amazon \
#                            --filters Name=name,Values="amzn2-ami-hvm-*-x86_64-gp2" \
#                            --query 'sort_by(Images,&CreationDate)[-1].ImageId'

aws_region = "us-east-1"
vpc_id     = "vpc-082d43041d1f41f6b"    #"vpc-REPLACE_ME"
subnet_id  = "subnet-0e0dd7f6d2a6b1e9e"
ami_id     = "ami-002192a70217ac181"
