# IT Tools - ECS Deployment

**Live:** https://tm.hassanuur.co.uk

## Overview

This project deploys IT Tools on AWS ECS Fargate using Terraform and GitHub Actions. The infrastructure is fully defined as code, the Docker image is hardened with a non-root user and multi-stage build, and deployments run through four separate pipelines with OIDC authentication so no AWS credentials are stored anywhere.

## App

![App](docs/screenshots/it-tools-page.png)

## Architecture

![Architecture Diagram](docs/architecture-diagram.png)

The app runs on ECS Fargate in private subnets behind an Application Load Balancer in the public subnets. The ALB handles HTTPS termination and redirects all HTTP traffic to HTTPS. The ACM certificate is validated automatically through Route 53. ECS tasks reach ECR to pull images through the NAT Gateway. Logs ship to CloudWatch with 7 day retention.

Networking: custom VPC with public and private subnets across eu-west-2a and eu-west-2b. The ALB sits in the public subnets and the ECS tasks sit in the private subnets so containers are never directly reachable from the internet.

Security: containers run as a non-root user on port 8080. ECS tasks only accept traffic from the ALB security group, not from the open internet. GitHub Actions authenticates with AWS through OIDC so no access keys are stored in the repo. ECR scans every image on push and Trivy runs in the build pipeline. Terraform state is stored in S3 with native locking.

## Local Setup

Docker, Terraform, AWS CLI configured

Run the app locally:

    cd app
    docker build -t it-tools .
    docker run -p 8080:8080 it-tools

    Visit http://localhost:8080
    curl http://localhost:8080/health

Deploy infrastructure with Terraform:

    Create an S3 bucket for state first, then update the bucket name in infra/backend.tf

    cd infra
    terraform init
    terraform plan -var="container_image=YOUR_ECR_URI/it-tools:latest"
    terraform apply -var="container_image=YOUR_ECR_URI/it-tools:latest"

    To tear it down:
    terraform destroy -var="container_image=placeholder"

## Project Structure

    ecs-project/
        app/
            Dockerfile
            nginx.conf
            .dockerignore
        infra/
            main.tf
            variables.tf
            outputs.tf
            provider.tf
            backend.tf
            modules/
                vpc/
                ecr/
                alb/
                ecs/
                acm/
        .github/
            workflows/
                app-build.yml
                terraform-plan.yml
                terraform-deploy.yml
                terraform-destroy.yml
        README.md

## How to Reproduce

Fork this repo, buy a domain and create a Route 53 hosted zone, create an S3 bucket for Terraform state with versioning enabled, set up OIDC in IAM and create a GitHub Actions role, add three GitHub secrets (AWS_ROLE_ARN, AWS_REGION, ECR_REPOSITORY), update the domain and bucket name in the infra files, then run the app build pipeline followed by the deploy pipeline.
