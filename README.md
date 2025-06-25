# shared-services

Central AWS infra for GitHub Actions self-hosted runners and networking.

## Structure

- `packer/` – Packer HCL for Golden Runner AMI
- `terraform/modules/` – Modules: `network`, `github-runner-asg`
- `terraform/envs/` – Stacks for `dev` and `prod`
- `.github/` – Workflows & Dependabot

## Prerequisites

- AWS credentials (or OIDC role) with VPC, EC2, IAM, ASG, SSM rights
- GitHub OIDC provider in AWS and a GitHub App/Token

## Quick Start (Dev)

```bash
cd terraform/envs/dev
terraform init
terraform apply -auto-approve
```