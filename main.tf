terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# SINGLE SERVER: Build + GitHub Enterprise Server (GHES)
# One server handles Docker builds, ECS deployments, AND self-hosted GitHub
# =============================================================================
resource "aws_instance" "atlas_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.atlas_server_instance_type  # m5.2xlarge recommended for GHES
  
  key_name = var.key_name
  subnet_id = var.subnet_id
  
  vpc_security_group_ids = [aws_security_group.atlas_server.id]
  iam_instance_profile = aws_iam_instance_profile.atlas_server.name
  
  root_block_device {
    volume_type = "gp3"
    volume_size = var.atlas_server_volume_size  # 500GB+ recommended for GHES
    encrypted   = true
  }
  
  tags = {
    Name = "atlas-build-and-ghes"
    Environment = "development"
  }
  
  user_data = <<-USERDATA
              #!/bin/bash
              set -e
              
              echo "=== Installing Docker and build tools ==="
              yum update -y
              yum install -y docker git-lfs
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              
              echo "=== Installing AWS CLI ==="
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip
              ./aws/install
              rm -rf aws awscliv2.zip
              
              echo "=== Installing Node.js 18 ==="
              curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
              yum install -y nodejs
              
              echo "=== Installing Terraform ==="
              yum install -y yum-utils
              yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              yum -y install terraform
              
              echo "=== Creating user rakibm ==="
              useradd -m -s /bin/bash rakibm
              echo "rakibm:Langley2322@" | chpasswd
              usermod -a -G docker,dialout,terraform rakibm
              
              echo "=== Installing GitHub Enterprise Server (GHES) ==="
              # Download GHES appliance (use latest stable version)
              wget -O /tmp/ghes-appliance.bin https://github-enterprise-downloads.example.com/ghes-3.11.0.bin
              chmod +x /tmp/ghes-appliance.bin
              
              # Install GHES (this takes 10-20 minutes)
              /tmp/ghes-appliance.bin --install --yes
              
              # Wait for GHES to start
              echo "Waiting for GHES to initialize..."
              sleep 60
              
              # Configure GHES admin user
              gh-ctl configure --hostname ghes.atlas.local --admin-password 'Langley2322@'
              
              echo "=== Setup complete ==="
              echo "Build tools ready"
              echo "GHES available at http://$(hostname -I | awk '{print $1}')"
              USERDATA
}

# Security Group - Atlas Server (Build + GHES)
resource "aws_security_group" "atlas_server" {
  name_prefix = "atlas-atlas-server-"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP (GHES)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS (GHES)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Git SSH"
    from_port   = 9418
    to_port     = 9418
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
    Name = "atlas-atlas-server-sg"
  }
}

# IAM Role for Atlas Server
resource "aws_iam_role" "atlas_server_role" {
  name = "atlas-atlas-server-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "atlas_server_ecr" {
  role       = aws_iam_role.atlas_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "atlas_server_ecs" {
  role       = aws_iam_role.atlas_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_instance_profile" "atlas_server" {
  name = "atlas-atlas-server-profile"
  role = aws_iam_role.atlas_server_role.name
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
