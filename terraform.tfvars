# Atlas Self-Hosted Infrastructure - Configuration
# Created: 2026-07-26
# Updated: Single server with GitHub Enterprise Server

# SSH Key Pair
key_name = "atlas-keypair"

# AWS Configuration
aws_region = "us-east-1"
subnet_id  = "subnet-0c88ce8f176477931"  # us-east-1a
vpc_id     = "vpc-043f37e30073af71a"

# Atlas Server (Build + GHES)
# Instance types:
#   - m5.2xlarge (8 vCPU, 32GB RAM) - Recommended for small teams
#   - m5.4xlarge (16 vCPU, 64GB RAM) - Recommended for medium teams
#   - r5.2xlarge (8 vCPU, 64GB RAM) - Memory-optimized for large repos
atlas_server_instance_type = "m5.2xlarge"

# EBS Volume Size (GB)
# GHES requires minimum 500GB, recommended 1TB+ for production
atlas_server_volume_size = 500
