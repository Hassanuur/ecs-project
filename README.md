# IT Tools — ECS Deployment

Self-hosted deployment of [IT Tools](https://github.com/CorentinTh/it-tools) on AWS ECS Fargate using Docker, Terraform, and GitHub Actions.

**Live:** https://tm.hassanuur.co.uk

## Overview

IT Tools is a collection of handy developer utilities including Base64 encoders, UUID generators, JWT decoders, and more. This project deploys it on AWS using production-grade infrastructure with private networking, HTTPS, automated container scanning, and fully automated CI/CD pipelines.

IT Tools was chosen because it is a real, actively used developer tool with 37k GitHub stars. It demonstrates a production-style deployment relevant to platform and cloud engineering roles.

## App Demo

![App running live](docs/screenshots/app-live.png)

## Architecture

![Architecture Diagram](docs/architecture.png)

**Infrastructure:**
- Custom VPC with public and private subnets across 2 availability zones
- ECS Fargate tasks in private subnets — not directly internet-facing
- Application Load Balancer in public subnets with HTTPS termination
- HTTP to HTTPS redirect enforced at ALB level
- ACM certificate auto-validated via Route 53 DNS
- NAT Gateway allowing private subnet tasks to pull from ECR
- CloudWatch logs with 7-day retention
- ECR with image scanning on every push

**Security:**
- Non-root container user running nginx on port 8080
- ECS tasks only accept traffic from ALB security group
- OIDC authentication for GitHub Actions — no static AWS keys stored
- Trivy vulnerability scanning in CI pipeline
- S3 remote state with native locking

## Local Setup

Requirements: Docker

```bash
cd app
docker build -t it-tools .
docker run -p 8080:8080 it-tools
# Visit http://localhost:8080
curl http://localhost:8080/health
# {"status":"ok"}
```

## Pipelines

| Pipeline | Trigger | Purpose |
|---|---|---|
| App Build | Push to app/** | Build image, push to ECR, Trivy scan |
| Terraform Plan | Pull request | fmt, validate, plan |
| Terraform Deploy | Push to infra/** or manual | Apply infrastructure |
| Terraform Destroy | Manual only | Tear down infrastructure |

![App Build Pipeline](docs/screenshots/pipeline-app-build.png)
![Terraform Plan Pipeline](docs/screenshots/pipeline-terraform-plan.png)
![Terraform Deploy Pipeline](docs/screenshots/pipeline-terraform-deploy.png)
![Terraform Destroy Pipeline](docs/screenshots/pipeline-terraform-destroy.png)

## Project Structure
