# Atlas Self-Hosted Infrastructure

**One server. GitHub Enterprise Server. Full control.**

## What's Included

- **Single EC2 instance** with GitHub Enterprise Server (self-managed Git)
- **Docker + build tools** for ECS deployments
- **AWS CLI + Terraform** pre-installed
- **IAM roles** for ECR/ECS access

## Cost

| Component | Cost |
|-----------|------|
| EC2 Instance (m5.2xlarge) | $140/month |
| EBS Storage (500GB gp3) | $40/month |
| Data Transfer | Variable |
| **Total** | **~$180/month** |

## Deployment

### Prerequisites

1. AWS CLI configured
2. Terraform installed
3. SSH key pair created

### Quick Start

```bash
# 1. Create SSH key pair (one-time)
aws ec2 create-key-pair --key-name atlas-keypair --query 'KeyMaterial' --output text > ~/.ssh/atlas-keypair.pem
chmod 400 ~/.ssh/atlas-keypair.pem

# 2. Initialize Terraform
cd aws-infra
terraform init

# 3. Review plan
terraform plan

# 4. Deploy (takes 10-20 minutes)
terraform apply

# 5. Connect to server
ssh -i ~/.ssh/atlas-keypair.pem rakibm@<SERVER_IP>
```

## Access

- **SSH:** `ssh -i ~/.ssh/atlas-keypair.pem rakibm@<SERVER_IP>`
- **GitHub Enterprise Server:** `http://<SERVER_IP>`
- **Username:** `rakibm`
- **Password:** `Langley2322@`

## GitHub Enterprise Server

GHES provides:
- ✅ Self-hosted Git (no GitHub dependency)
- ✅ Private repos with full history
- ✅ Web UI for browsing code
- ✅ REST API for automation
- ✅ Issues for task tracking
- ✅ Actions for CI/CD (optional)
- ✅ No external dependencies

## Architecture

```
┌─────────────────────────────────────┐
│  Atlas Server (m5.2xlarge)          │
│  ┌───────────────────────────────┐  │
│  │ GitHub Enterprise Server      │  │
│  │ - Git hosting (repos, issues) │  │
│  │ - Web UI (http://<IP>)        │  │
│  │ - REST API                    │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Docker + Build Tools          │  │
│  │ - Docker builds               │  │
│  │ - ECS deployments             │  │
│  │ - Node.js 18                  │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ AWS CLI + Terraform           │  │
│  │ - ECR access                  │  │
│  │ - ECS access                  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Destroy

```bash
terraform destroy
```

## Notes

- GHES installation takes 10-20 minutes on first boot
- Server is fully self-contained - no external dependencies
- Can scale to larger instance types as needed
- Backup recommended for production use

---

**Created:** 2026-07-26  
**Updated:** Single server with GHES (no Gitea)
