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
# BUILD SERVER (t3.large)
# For Docker builds, ECS deployments, general development
# =============================================================================
resource "aws_instance" "build_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.build_server_instance_type
  
  key_name = var.key_name
  subnet_id = var.subnet_id
  
  vpc_security_group_ids = [aws_security_group.build_server.id]
  iam_instance_profile = aws_iam_instance_profile.build_server.name
  
  root_block_device {
    volume_type = "gp3"
    volume_size = var.build_server_volume_size
    encrypted   = true
  }
  
  tags = {
    Name = "atlas-build-server"
    Environment = "development"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              echo "=== Installing Docker and build tools ==="
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              
              echo "=== Installing AWS CLI ==="
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip
              ./aws/install
              rm -rf aws awscliv2.zip
              
              echo "=== Installing Git ==="
              yum install -y git
              
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
              
              echo "=== Setup complete ==="
              EOF
}

# =============================================================================
# GITHUB ENTERPRISE SERVER (Optional)
# Requires: 8+ CPU, 64GB+ RAM, 500GB+ storage
# Uncomment and configure if needed
# =============================================================================
# resource "aws_instance" "ghes_server" {
#   ami           = data.aws_ami.amazon_linux_2023.id
#   instance_type = var.ghes_instance_type  # e.g., m5.2xlarge or r5.2xlarge
#   
#   key_name = var.key_name
#   subnet_id = var.subnet_id
#   
#   vpc_security_group_ids = [aws_security_group.ghes.id]
#   
#   root_block_device {
#     volume_type = "gp3"
#     volume_size = var.ghes_volume_size  # Minimum 500GB recommended
#     encrypted   = true
#   }
#   
#   tags = {
#     Name = "atlas-ghes-server"
#     Environment = "development"
#   }
#   
#   user_data = <<-EOF
#               #!/bin/bash
#               # GHES installation script
#               # See: https://docs.github.com/en/enterprise-server@3.11/admin/installation/installing-github-enterprise-server
#               echo "Installing GitHub Enterprise Server..."
#               # Download and install GHES
#               # Configure initial admin user
#               EOF
# }

# =============================================================================
# GITEA SERVER (Lightweight Alternative to GHES)
# Requires: 2+ CPU, 4GB+ RAM, 50GB+ storage
# Much cheaper than GHES, good for self-hosted Git
# =============================================================================
resource "aws_instance" "gitea_server" {
  count = var.enable_gitea ? 1 : 0
  
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.gitea_instance_type  # t3.medium is usually sufficient
  
  key_name = var.key_name
  subnet_id = var.subnet_id
  
  vpc_security_group_ids = [aws_security_group.gitea.id]
  
  root_block_device {
    volume_type = "gp3"
    volume_size = var.gitea_volume_size
    encrypted   = true
  }
  
  tags = {
    Name = "atlas-gitea-server"
    Environment = "development"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              echo "=== Installing Gitea ==="
              yum update -y
              yum install -y git sqlite git-lfs
              
              # Download Gitea (latest stable)
              GITEA_VERSION=1.21.0
              wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64
              chmod +x /usr/local/bin/gitea
              
              # Create gitea user
              useradd --system --shell /bin/bash --comment 'Gitea' --home-dir /home/gitea gitea
              mkdir -p /home/gitea/{data,log}
              chown -R gitea:gitea /home/gitea
              
              # Create systemd service
              cat > /etc/systemd/system/gitea.service << 'EOF'
              [Unit]
              Description=Gitea
              After=syslog.target
              After=network.target
              
              [Service]
              Type=simple
              User=gitea
              Group=gitea
              WorkingDirectory=/var/lib/gitea/
              ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
              Restart=always
              Environment=USER=gitea HOME=/home/gitea GITEA_WORK_DIR=/var/lib/gitea
              
              [Install]
              WantedBy=multi-user.target
              EOF
              
              systemctl daemon-reload
              systemctl enable gitea
              systemctl start gitea
              
              echo "=== Gitea installed at http://$(hostname -I | awk '{print $1}'):3000 ==="
              EOF
}

# Security Group - Build Server
resource "aws_security_group" "build_server" {
  name_prefix = "atlas-build-server-"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "atlas-build-server-sg"
  }
}

# Security Group - GHES (if enabled)
# resource "aws_security_group" "ghes" {
#   name_prefix = "atlas-ghes-"
#   vpc_id      = var.vpc_id
#   
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   
#   ingress {
#     description = "HTTP (Git)"
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   
#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   
#   tags = {
#     Name = "atlas-ghes-sg"
#   }
# }

# Security Group - Gitea (if enabled)
resource "aws_security_group" "gitea" {
  count = var.enable_gitea ? 1 : 0
  
  name_prefix = "atlas-gitea-"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Gitea Web UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP (Git)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "atlas-gitea-sg"
  }
}

# IAM Role for Build Server
resource "aws_iam_role" "build_server_role" {
  name = "atlas-build-server-role"
  
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

resource "aws_iam_role_policy_attachment" "build_server_ecr" {
  role       = aws_iam_role.build_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "build_server_ecs" {
  role       = aws_iam_role.build_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_instance_profile" "build_server" {
  name = "atlas-build-server-profile"
  role = aws_iam_role.build_server_role.name
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

# Outputs - Build Server
output "build_server_public_ip" {
  description = "Public IP of the build server"
  value       = aws_instance.build_server.public_ip
}

output "build_server_private_ip" {
  description = "Private IP of the build server"
  value       = aws_instance.build_server.private_ip
}

output "build_server_ssh_command" {
  description = "SSH command to connect as rakibm user"
  value       = "ssh -i ${var.key_path} rakibm@${aws_instance.build_server.public_ip}"
}

# Outputs - Gitea (if enabled)
output "gitea_public_ip" {
  description = "Public IP of the Gitea server"
  value       = var.enable_gitea ? aws_instance.gitea_server[0].public_ip : "Gitea not enabled"
}

output "gitea_url" {
  description = "Gitea web URL"
  value       = var.enable_gitea ? "http://${aws_instance.gitea_server[0].public_ip}:3000" : "Gitea not enabled"
}

output "gitea_ssh_command" {
  description = "SSH command to connect to Gitea server"
  value       = var.enable_gitea ? "ssh -i ${var.key_path} rakibm@${aws_instance.gitea_server[0].public_ip}" : "Gitea not enabled"
}
