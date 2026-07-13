# ── Dev values — replace with your real IDs ──────────────
# Handy commands to find values:
#
#   VPC:    aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
#             --query 'Vpcs[0].VpcId' --output text
#
#   Subnet: aws ec2 describe-subnets \
#             --filters Name=vpc-id,Values=<your-vpc-id> \
#             --query 'Subnets[0].SubnetId' --output text
#
#   AMI:    aws ssm get-parameter \
#             --name /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
#             --query Parameter.Value --output text

#aws_region = "us-east-1"
#vpc_id     = "vpc-REPLACE_ME"
#subnet_id  = "subnet-REPLACE_ME"
#ami_id     = "ami-REPLACE_ME"

aws_region = "us-east-1"
vpc_id     = "vpc-082d43041d1f41f6b"    #"vpc-REPLACE_ME"
subnet_id  = "subnet-0e0dd7f6d2a6b1e9e"
ami_id     = "ami-002192a70217ac181"

