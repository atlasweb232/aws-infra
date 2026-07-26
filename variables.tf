variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# BUILD SERVER (t3.large)
# For Docker builds, ECS deployments, general development
# =============================================================================
variable "build_server_instance_type" {
  description = "EC2 instance type for build server"
  type        = string
  default     = "t3.large"  # 2 vCPU, 8GB RAM
  
  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge"], var.build_server_instance_type)
    error_message = "Choose: t3.medium (4GB), t3.large (8GB), t3.xlarge (16GB), t3.2xlarge (32GB)"
  }
}

variable "build_server_volume_size" {
  description = "EBS volume size for build server (GB)"
  type        = number
  default     = 100  # 100GB for builds + Docker images
  
  validation {
    condition     = var.build_server_volume_size >= 50
    error_message = "Build server volume must be at least 50GB"
  }
}

# =============================================================================
# GITHUB ENTERPRISE SERVER (GHES) - Optional
# Requires: 8+ CPU, 64GB+ RAM, 500GB+ storage
# Commented out by default - uncomment if needed
# =============================================================================
variable "enable_ghes" {
  description = "Enable GitHub Enterprise Server"
  type        = bool
  default     = false  # Set to true to enable (requires much larger instance)
}

variable "ghes_instance_type" {
  description = "EC2 instance type for GHES"
  type        = string
  default     = "m5.2xlarge"  # 8 vCPU, 32GB RAM - minimum for GHES
  
  validation {
    condition     = var.ghes_instance_type != "t3.medium" && var.ghes_instance_type != "t3.large"
    error_message = "GHES requires at least 8 vCPU and 32GB RAM (e.g., m5.2xlarge or r5.2xlarge)"
  }
}

variable "ghes_volume_size" {
  description = "EBS volume size for GHES (GB)"
  type        = number
  default     = 500  # Minimum 500GB for GHES
  
  validation {
    condition     = var.ghes_volume_size >= 500
    error_message = "GHES volume must be at least 500GB"
  }
}

# =============================================================================
# GITEA SERVER (Lightweight Alternative to GHES)
# Requires: 2+ CPU, 4GB+ RAM, 50GB+ storage
# Much cheaper than GHES, good for self-hosted Git
# =============================================================================
variable "enable_gitea" {
  description = "Enable Gitea (lightweight self-hosted Git)"
  type        = bool
  default     = true  # Recommended for most use cases
  
  validation {
    condition     = var.enable_gitea != null
    error_message = "Must specify whether to enable Gitea"
  }
}

variable "gitea_instance_type" {
  description = "EC2 instance type for Gitea"
  type        = string
  default     = "t3.medium"  # 2 vCPU, 4GB RAM is usually sufficient
  
  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge"], var.gitea_instance_type)
    error_message = "Choose from: t3.medium (4GB), t3.large (8GB), t3.xlarge (16GB)"
  }
}

variable "gitea_volume_size" {
  description = "EBS volume size for Gitea (GB)"
  type        = number
  default     = 100  # 100GB for repositories and uploads
  
  validation {
    condition     = var.gitea_volume_size >= 50
    error_message = "Gitea volume must be at least 50GB"
  }
}

# =============================================================================
# SHARED SETTINGS
# =============================================================================
variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "atlas-keypair"
}

variable "key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/atlas-keypair.pem"
}

variable "vpc_id" {
  description = "VPC ID for the servers"
  type        = string
  default     = "vpc-043f37e30073af71a"
}

variable "subnet_id" {
  description = "Subnet ID for the servers"
  type        = string
  default     = null
}

variable "username" {
  description = "Username to create on the build server"
  type        = string
  default     = "rakibm"
}

variable "user_password" {
  description = "Password for the new user"
  type        = string
  default     = "Langley2322@"
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}
