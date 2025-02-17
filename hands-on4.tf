# Configure the AWS Provider
provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

#1 VPC作成
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "iac-vpc"
  }
}

#2 インターネットゲートウェイ作成
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "iac-igw"
  }
}

#3 ルートテーブル作成
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }
  tags = {
    Name = "iac-route-table"
  }
}

#4 サブネット作成
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = var.subnet_prefix[0].name
  }
}

#5 サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

#6 セキュリティグループ作成（ポート22,80,443許可）
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web"
  }
}

#7 ENI作成
resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.main.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

#8 EIP作成
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.main]
}

#9 Webサーバー構築
resource "aws_instance" "web_server" {
  ami               = "ami-0b828c1c5ac3f13ee" # Amazon Linux 2 AMI for ap-northeast-1
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  key_name          = "your-key-pair-name" # Replace with your key pair name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_server_nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo systemctl start httpd
              sudo systemctl enable httpd
              sudo bash -c 'echo "<h1>Hello World from Terraform</h1>" > /var/www/html/index.html'
              EOF

  tags = {
    Name = "web_server"
  }
}
