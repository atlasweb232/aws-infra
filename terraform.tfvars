# =============================================================================
# BUILD SERVER - Core Configuration
# =============================================================================
aws_region = "us-east-1"
key_name = "atlas-keypair"
key_path = "~/.ssh/atlas-keypair.pem"
vpc_id = "vpc-043f37e30073af71a"
username = "rakibm"
user_password = "Langley2322@"
environment = "development"

# =============================================================================
# BUILD SERVER (Docker builds, ECS deployments)
# =============================================================================
build_server_instance_type = "t3.large"  # 2 vCPU, 8GB RAM - recommended
build_server_volume_size = 100           # 100GB for builds + Docker images

# =============================================================================
# GITEA (Lightweight self-hosted Git) - RECOMMENDED
# =============================================================================
enable_gitea = true
gitea_instance_type = "t3.medium"        # 2 vCPU, 4GB RAM - usually sufficient
gitea_volume_size = 100                  # 100GB for repositories

# =============================================================================
# GITHUB ENTERPRISE SERVER (GHES) - OPTIONAL
# Requires: 8+ CPU, 64GB+ RAM, 500GB+ storage
# Much more expensive than Gitea
# =============================================================================
enable_ghes = false  # Set to true if you need full GHES (expensive!)
ghes_instance_type = "m5.2xlarge"        # 8 vCPU, 32GB RAM - minimum
ghes_volume_size = 500                   # Minimum 500GB
