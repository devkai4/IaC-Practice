#!/bin/bash
set -euo pipefail

# Variables
PREFIX="cloud01"

# Get subnet IDs for ALB (need 2 public subnets)
PUBLIC_SUBNET_1=$(aws ec2 describe-subnets \
  --filters Name=tag:Name,Values=${PREFIX}-public-subnet-1a \
  --query "Subnets[*].SubnetId" --output text)
  
PUBLIC_SUBNET_2=$(aws ec2 describe-subnets \
  --filters Name=tag:Name,Values=${PREFIX}-public-subnet-1c \
  --query "Subnets[*].SubnetId" --output text)

# Get security group ID
ELB_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
  --filters Name=tag:Name,Values=${PREFIX}-elb-sg \
  --query "SecurityGroups[*].GroupId" --output text)

# Create target group
TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
  --name ${PREFIX}-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --target-type instance \
  --health-check-path / \
  --tags Key=Name,Value=${PREFIX}-tg \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

# Create ALB
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name ${PREFIX}-alb \
  --subnets $PUBLIC_SUBNET_1 $PUBLIC_SUBNET_2 \
  --security-groups $ELB_SECURITY_GROUP_ID \
  --tags Key=Name,Value=${PREFIX}-alb \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Create listener
aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# Register EC2 instance to target group
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=${PREFIX}-web-01 \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws elbv2 register-targets \
  --target-group-arn $TARGET_GROUP_ARN \
  --targets Id=$INSTANCE_ID