# =============================================================================
# Atlas Self-Hosted Infrastructure - Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the server"
  type        = string
  default     = "subnet-0c88ce8f176477931"  # us-east-1a
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = "vpc-043f37e30073af71a"
}

variable "atlas_server_instance_type" {
  description = "EC2 instance type for the Atlas server (build + GHES)"
  type        = string
  default     = "m5.2xlarge"  # 8 vCPU, 32GB RAM - recommended for GHES
}

variable "atlas_server_volume_size" {
  description = "EBS volume size in GB for the Atlas server"
  type        = number
  default     = 500
}
