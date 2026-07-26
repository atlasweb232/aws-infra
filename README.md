# Atlas AWS Infrastructure

Terraform infrastructure-as-code for Atlas project AWS resources.

## What is This?

This repository defines your AWS infrastructure using **Terraform** — a tool that lets you create and manage AWS resources (servers, networks, IAM roles) using code instead of clicking through the AWS console.

### Why Terraform?

- ✅ **Reproducible** — Same infrastructure every time
- ✅ **Version controlled** — Track changes over time
- ✅ **One command to deploy** — `terraform apply`
- ✅ **Cost tracking** — See exactly what you're spending
- ✅ **Easy to modify** — Change a number, re-apply

## Infrastructure Options

### Option 1: Gitea + Build Server (Recommended)
| Component | Instance | vCPU | RAM | Storage | Monthly Cost |
|-----------|----------|------|-----|---------|--------------|
| Build Server | t3.large | 2 | 8GB | 100GB | $60 |
| Gitea Server | t3.medium | 2 | 4GB | 100GB | $30 |
| **Total** | | **4** | **12GB** | **200GB** | **~$98** |

### Option 2: Build Server Only
| Component | Instance | vCPU | RAM | Storage | Monthly Cost |
|-----------|----------|------|-----|---------|--------------|
| Build Server | t3.large | 2 | 8GB | 100GB | $60 |
| **Total** | | **2** | **8GB** | **100GB** | **~$64** |

### Option 3: GHES + Build Server (Enterprise)
| Component | Instance | vCPU | RAM | Storage | Monthly Cost |
|-----------|----------|------|-----|---------|--------------|
| Build Server | t3.large | 2 | 8GB | 100GB | $60 |
| GHES Server | m5.2xlarge | 8 | 32GB | 500GB | $280 |
| **Total** | | **10** | **40GB** | **600GB** | **~$364** |

## Quick Start

### Prerequisites
- Terraform installed (`terraform -v`)
- AWS CLI configured (`aws configure`)
- SSH key pair created

### 1. Create SSH Key

```bash
aws ec2 create-key-pair --key-name atlas-keypair --query 'KeyMaterial' --output text > ~/.ssh/atlas-keypair.pem
chmod 400 ~/.ssh/atlas-keypair.pem
```

### 2. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## File Structure

```
.
├── main.tf                 # EC2 instances, security groups, IAM roles
├── variables.tf            # Configuration variables (instance types, volumes)
├── outputs.tf              # Output values (IP addresses, SSH commands)
├── terraform.tfvars.example # Example configuration
├── deploy.bat              # Windows deployment script
└── README.md               # This file
```

## What Each File Does

| File | Purpose |
|------|---------|
| `main.tf` | Defines the actual infrastructure (servers, networks, roles) |
| `variables.tf` | Parameters you can change (instance types, storage sizes) |
| `outputs.tf` | Information returned after deployment (IPs, SSH commands) |
| `terraform.tfvars` | Your actual configuration (copy from `.example`) |
| `deploy.bat` | One-click Windows deployment script |

## Servers Created

### Build Server (Always Created)
- **Purpose:** Docker builds, ECS deployments, Node.js builds
- **Pre-installed:** Docker, AWS CLI, Git, Node.js 18, Terraform
- **User:** `rakibm` (password: `Langley2322@`)

### Gitea Server (Optional - `enable_gitea = true`)
- **Purpose:** Self-hosted Git server (like GitHub, but on your infra)
- **Web UI:** `http://<GITEA_IP>:3000`
- **Features:** Unlimited repos, Git LFS, web UI

### GHES Server (Optional - `enable_ghes = true`)
- **Purpose:** Full GitHub Enterprise Server
- **Cost:** $280/month + GitHub licensing ($21/user/month)
- **Features:** GitHub Actions, Apps, enterprise features

## Cost Management

### Stop When Not in Use
```bash
# Stop instances (still pays ~$8/month for EBS storage)
aws ec2 stop-instances --instance-ids <ID1> <ID2>

# Terminate completely (no charges)
terraform destroy
```

### Reserved Instances (Save 30-40%)
```bash
# Contact AWS for reserved instance pricing
# Example: t3.large reserved = ~$40/month instead of $60/month
```

## Security

- ✅ EBS volumes encrypted
- ✅ IAM roles for least-privilege access
- ✅ Security groups restrict access
- ⚠️ Password authentication enabled (change after first login)

## Troubleshooting

### "Permission denied (publickey)"
```bash
ssh -i ~/.ssh/atlas-keypair.pem rakibm@<IP>
```

### Docker not working
```bash
sudo usermod -aG docker rakibm
# Logout and login again
```

### Gitea not starting
```bash
systemctl status gitea
journalctl -u gitea -f
sudo systemctl restart gitea
```

## Next Steps

1. ✅ Create SSH key
2. ✅ Configure `terraform.tfvars`
3. ⬜ Run `terraform init && terraform apply`
4. ⬜ Connect to servers via SSH
5. ⬜ Clone repositories to Gitea (if enabled)
6. ⬜ Test build and deploy workflow

## Related Repositories

- [atlas-emailreact](https://github.com/atlasweb232/atlas-emailreact) - Web application
- [atlas-email-desktop](https://github.com/atlasweb232/atlas-email-desktop) - Desktop application

## Support

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2)
- [Gitea Documentation](https://docs.gitea.io)
