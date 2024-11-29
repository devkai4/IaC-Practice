#!/bin/bash
set -euo pipefail

echo "Starting security group creation script..."

# Variables
PREFIX="cloud01"
echo "Using prefix: ${PREFIX}"

echo "Fetching VPC ID..."
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=${PREFIX}-vpc --query "Vpcs[*].VpcId" --output text) && echo "Found VPC ID: ${VPC_ID}"

## Security group
# ELB
echo "Creating ELB Security Group..."
ELB_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
--group-name ${PREFIX}-elb-sg \
--description ${PREFIX}-elb-sg \
--vpc-id $VPC_ID \
--tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${PREFIX}-elb-sg}]" \
--query "GroupId" --output text) && echo "Created ELB Security Group: ${ELB_SECURITY_GROUP_ID}"

echo "Adding ingress rules for HTTP/HTTPS (ports 80/443)..."
aws ec2 authorize-security-group-ingress \
--group-id $ELB_SECURITY_GROUP_ID \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id $ELB_SECURITY_GROUP_ID \
--protocol tcp \
--port 443 \
--cidr 0.0.0.0/0

# EC2
echo "Creating EC2 Security Group..."
EC2_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
--group-name ${PREFIX}-ec2-sg \
--description ${PREFIX}-ec2-sg \
--vpc-id $VPC_ID \
--tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${PREFIX}-ec2-sg}]" \
--query "GroupId" --output text) && echo "Created EC2 Security Group: ${EC2_SECURITY_GROUP_ID}"

# Systems Manager Session Managerを使用する場合はSSHルールは不要
# 従来のSSH接続が必要な場合は、会社の固定IPやVPN出口IPを指定
echo "Adding ingress rule for SSH (port 22) from allowed IP ranges..."
aws ec2 authorize-security-group-ingress \
--group-id $EC2_SECURITY_GROUP_ID \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0./0 # 危険
# 例：社内ネットワークのCIDR
# --cidr 10.0.0.0/8  

echo "Adding ingress rule for HTTP (port 80) from ELB Security Group..."
aws ec2 authorize-security-group-ingress \
--group-id $EC2_SECURITY_GROUP_ID \
--protocol tcp \
--port 80 \
--source-group $ELB_SECURITY_GROUP_ID

# RDS
echo "Creating RDS Security Group..."
RDS_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
--group-name ${PREFIX}-rds-sg \
--description ${PREFIX}-rds-sg \
--vpc-id $VPC_ID \
--tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=${PREFIX}-rds-sg}]" \
--query "GroupId" --output text) && echo "Created RDS Security Group: ${RDS_SECURITY_GROUP_ID}"

echo "Adding ingress rule for MySQL (port 3306) from EC2 Security Group..."
aws ec2 authorize-security-group-ingress \
--group-id $RDS_SECURITY_GROUP_ID \
--protocol tcp \
--port 3306 \
--source-group $EC2_SECURITY_GROUP_ID

echo "Security group creation completed successfully!"