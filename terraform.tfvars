# Atlas Self-Hosted Infrastructure
# Created: 2026-07-26
# Status: Deployed

# Build Server (t3.large - 2 vCPU, 8GB RAM, 100GB storage)
build_server_instance_type = "t3.large"
build_server_volume_size   = 100

# Gitea Server (t3.medium - 2 vCPU, 4GB RAM, 100GB storage)
enable_gitea = true
gitea_instance_type = "t3.medium"
gitea_volume_size   = 100

# SSH Key
key_pair_name = "atlas-keypair"

# AWS Region
region = "us-east-1"
subnet_id = "subnet-0c88ce8f176477931"
