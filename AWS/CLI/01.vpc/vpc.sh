# Variables
PREFIX="cloud01"

# VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --instance-tenancy default \
  --tag-specification "ResourceType=vpc,Tags=[{Key=Name,Value=${PREFIX}-vpc}]" \
  --query "Vpc.VpcId" --output text)

echo "Created VPC: $VPC_ID"

# InternetGateway
INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
  --tag-specification "ResourceType=internet-gateway,Tags=[{Key=Name,Value=${PREFIX}-igw}]" \
  --query "InternetGateway.InternetGatewayId" --output text)

echo "Created Internet Gateway: $INTERNET_GATEWAY_ID"

aws ec2 attach-internet-gateway \
  --internet-gateway-id $INTERNET_GATEWAY_ID \
  --vpc-id $VPC_ID

# Public subnet
PUBLIC_SUBNET_1a_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.11.0/24 \
  --availability-zone ap-northeast-1a \
  --tag-specification "ResourceType=subnet,Tags=[{Key=Name,Value=${PREFIX}-public-subnet-1a}]" \
  --query "Subnet.SubnetId" --output text)

echo "Created Public Subnet 1a: $PUBLIC_SUBNET_1a_ID"

PUBLIC_SUBNET_1c_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.12.0/24 \
  --availability-zone ap-northeast-1c \
  --tag-specification "ResourceType=subnet,Tags=[{Key=Name,Value=${PREFIX}-public-subnet-1c}]" \
  --query "Subnet.SubnetId" --output text)

echo "Created Public Subnet 1c: $PUBLIC_SUBNET_1c_ID"

# Public route table
PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specification "ResourceType=route-table,Tags=[{Key=Name,Value=${PREFIX}-public-route}]" \
  --query "RouteTable.RouteTableId" --output text)

echo "Created Route Table: $PUBLIC_ROUTE_TABLE_ID"

aws ec2 create-route \
  --route-table-id $PUBLIC_ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $INTERNET_GATEWAY_ID

# Subnet attach
aws ec2 associate-route-table \
  --route-table-id $PUBLIC_ROUTE_TABLE_ID \
  --subnet-id $PUBLIC_SUBNET_1a_ID

aws ec2 associate-route-table \
  --route-table-id $PUBLIC_ROUTE_TABLE_ID \
  --subnet-id $PUBLIC_SUBNET_1c_ID
