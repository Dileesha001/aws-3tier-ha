# Architecture Overview — AWS Three-Tier HA Guestbook

## High-Level Design

```
Internet
   │
   ▼
┌─────────────────────────────────────────────────┐
│  Internet-Facing ALB  (public subnets, 2 AZs)   │
└───────────────────┬─────────────────────────────┘
                    │ HTTP (port 80)
                    ▼
┌─────────────────────────────────────────────────┐
│  Auto Scaling Group  (private subnets, 2 AZs)   │
│                                                  │
│  EC2 instance (sg-app)                           │
│  ├── Nginx  → serves /assets/* from dist/        │
│  └── Flask  → handles /api/*, /health            │
└───────────────────┬─────────────────────────────┘
                    │ SSL (port 5432)
                    ▼
┌─────────────────────────────────────────────────┐
│  RDS PostgreSQL  (private subnet, Single-AZ)     │
│  Database: portfolio_app                         │
│  Table:    messages (id, name, message,          │
│            created_at)                           │
└─────────────────────────────────────────────────┘
```

## Tiers

| Tier | AWS Resource | Subnets | Security Group |
|------|-------------|---------|----------------|
| Presentation | Internet-Facing ALB | Public (2 AZs) | sg-alb (inbound 80 from 0.0.0.0/0) |
| Application | EC2 in ASG | Private app (2 AZs) | sg-app (inbound 80 from sg-alb only) |
| Data | RDS PostgreSQL | Private data (2 AZs) | sg-rds (inbound 5432 from sg-app only) |

## Request Flow

1. **Browser → ALB**: HTTP request arrives at the internet-facing ALB DNS name.
2. **ALB → EC2**: ALB forwards to a healthy target in the ASG using round-robin.
3. **Nginx (EC2)**: Serves pre-built Vite static assets (`/assets/*`) directly from disk; proxies `/api/*` and `/health` to Flask on `127.0.0.1:8000`.
4. **Flask (EC2)**: Validates input, opens a short-lived SSL connection to RDS, executes a parameterised query, returns JSON.
5. **RDS**: Stores or retrieves rows from the `messages` table. No direct internet access.

## Networking

- **VPC**: Single VPC with public and private subnet pairs in each of two AZs.
- **NAT Gateways**: One per AZ; allow EC2 instances in private subnets to reach the internet for package installs and Secrets Manager.
- **Internet Gateway**: Attached to the VPC; used only by the ALB and NAT Gateway Elastic IPs.
- **Route tables**: Public subnets route `0.0.0.0/0` to IGW; private subnets route `0.0.0.0/0` to NAT GW.

## Secrets and Configuration

Credentials are never baked into AMIs or committed to source control.
At instance launch, `user-data.sh`:
1. Retrieves the RDS password from **AWS Secrets Manager** via the instance role.
2. Exports `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` as environment variables for Flask.

The EC2 instance profile grants only `secretsmanager:GetSecretValue` for the specific secret ARN (`read-secret-policy.json`).

## Scaling

The ASG uses a target-tracking policy. When average CPU exceeds the threshold, new instances are launched in the next available AZ, automatically registered with the ALB target group, and warmed up before receiving traffic. Existing instances are drained gracefully on scale-in.

## Known Limitations

| Limitation | Impact | Mitigation Path |
|-----------|--------|-----------------|
| RDS is Single-AZ | DB failure = outage | Enable Multi-AZ in RDS settings |
| Build-on-launch (npm ci on EC2) | Slow cold start (~3 min) | Pre-build AMI or S3 artifact pipeline |
| HTTP only (no TLS termination at ALB) | Data in transit unencrypted | Add ACM certificate + HTTPS listener |
| No authentication / moderation | Public write access | Add WAF, Cognito, or admin review queue |

## Infrastructure as Code

All AWS resources are managed by Terraform in `infrastructure/terraform/`.
Resources were originally created manually and subsequently imported; the state file tracks the live environment. Apply changes with:

```powershell
terraform validate
terraform plan -out=<name>.tfplan
terraform apply <name>.tfplan
```

Never commit `terraform.tfstate`, saved plans, or `.env` files.
