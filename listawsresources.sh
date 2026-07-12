#!/bin/bash

# AWS Multi-Region Resource Inventory Script
# Requires:
#   - AWS CLI configured
#   - jq installed
#
# Usage:
#   chmod +x aws_inventory.sh
#   ./aws_inventory.sh

OUTPUT_FILE="aws_inventory_$(date +%Y%m%d_%H%M%S).txt"

echo "AWS Resource Inventory Report" > $OUTPUT_FILE
echo "Generated on: $(date)" >> $OUTPUT_FILE
echo "==========================================" >> $OUTPUT_FILE

# Get all AWS regions
REGIONS=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

for REGION in $REGIONS
do
    echo "" | tee -a $OUTPUT_FILE
    echo "##########################################" | tee -a $OUTPUT_FILE
    echo "Region: $REGION" | tee -a $OUTPUT_FILE
    echo "##########################################" | tee -a $OUTPUT_FILE

    # EC2 Instances
    echo "" | tee -a $OUTPUT_FILE
    echo "EC2 Instances:" | tee -a $OUTPUT_FILE
    aws ec2 describe-instances \
        --region $REGION \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # EBS Volumes
    echo "" | tee -a $OUTPUT_FILE
    echo "EBS Volumes:" | tee -a $OUTPUT_FILE
    aws ec2 describe-volumes \
        --region $REGION \
        --query 'Volumes[*].[VolumeId,Size,State]' \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # S3 Buckets (Global)
    if [[ "$REGION" == "us-east-1" ]]; then
        echo "" | tee -a $OUTPUT_FILE
        echo "S3 Buckets:" | tee -a $OUTPUT_FILE
        aws s3 ls 2>/dev/null | tee -a $OUTPUT_FILE
    fi

    # RDS Databases
    echo "" | tee -a $OUTPUT_FILE
    echo "RDS Instances:" | tee -a $OUTPUT_FILE
    aws rds describe-db-instances \
        --region $REGION \
        --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]' \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # Lambda Functions
    echo "" | tee -a $OUTPUT_FILE
    echo "Lambda Functions:" | tee -a $OUTPUT_FILE
    aws lambda list-functions \
        --region $REGION \
        --query 'Functions[*].[FunctionName,Runtime]' \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # ECS Clusters
    echo "" | tee -a $OUTPUT_FILE
    echo "ECS Clusters:" | tee -a $OUTPUT_FILE
    aws ecs list-clusters \
        --region $REGION \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # EKS Clusters
    echo "" | tee -a $OUTPUT_FILE
    echo "EKS Clusters:" | tee -a $OUTPUT_FILE
    aws eks list-clusters \
        --region $REGION \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # Load Balancers
    echo "" | tee -a $OUTPUT_FILE
    echo "Load Balancers:" | tee -a $OUTPUT_FILE
    aws elbv2 describe-load-balancers \
        --region $REGION \
        --query 'LoadBalancers[*].[LoadBalancerName,Type,State.Code]' \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

    # NAT Gateways
    echo "" | tee -a $OUTPUT_FILE
    echo "NAT Gateways:" | tee -a $OUTPUT_FILE
    aws ec2 describe-nat-gateways \
        --region $REGION \
        --query 'NatGateways[*].[NatGatewayId,State]' \
        --output table 2>/dev/null | tee -a $OUTPUT_FILE

done

echo "" | tee -a $OUTPUT_FILE
echo "Inventory completed."
echo "Report saved to: $OUTPUT_FILE"
