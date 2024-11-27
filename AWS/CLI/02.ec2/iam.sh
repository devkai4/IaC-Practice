#!/bin/bash
set -euo pipefail

# Variables
PREFIX="cloud01"
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

echo "Starting IAM role and instance profile creation process..."

# Create IAM Role
echo "Creating IAM role: ${PREFIX}-ec2-role..."
aws iam create-role \
--role-name ${PREFIX}-ec2-role \
--assume-role-policy-document file://param/AssumeRole.json
echo "✓ IAM role created successfully"

# Create Instance Profile
echo "Creating instance profile: ${PREFIX}-ec2-role..."
aws iam create-instance-profile \
--instance-profile-name ${PREFIX}-ec2-role
echo "✓ Instance profile created successfully"

# Add Role to Instance Profile
echo "Attaching role to instance profile..."
aws iam add-role-to-instance-profile \
--role-name ${PREFIX}-ec2-role \
--instance-profile-name ${PREFIX}-ec2-role
echo "✓ Role attached to instance profile successfully"

# Attach Policy to Role
echo "Attaching AdministratorAccess policy to role..."
aws iam attach-role-policy \
--policy-arn $POLICY_ARN \
--role-name ${PREFIX}-ec2-role
echo "✓ Policy attached successfully"

echo "==================================="
echo "Setup completed successfully!"
echo "Role name: ${PREFIX}-ec2-role"
echo "Instance profile name: ${PREFIX}-ec2-role"
echo "Attached policy: AdministratorAccess"
echo "==================================="