# Spring Boot → EKS Deployment Project

Production-ready CI/CD pipeline deploying a Java 21 / Spring Boot 3.3 application to AWS EKS using GitHub Actions.

## Project Structure

```
├── .github/workflows/ci-cd.yml    # GitHub Actions pipeline
├── docker/Dockerfile              # Multi-stage Docker build
├── terraform/
│   ├── modules/
│   │   ├── vpc/                   # VPC with public/private subnets, NAT
│   │   └── eks/                   # EKS cluster, node groups, ECR, OIDC
│   └── environments/
│       ├── dev/                   # Dev environment (2 AZs, t3.medium)
│       └── prod/                  # Prod environment (3 AZs, t3.large)
├── helm/springboot-app/           # Helm chart with per-env values
│   ├── templates/                 # Deployment, Service, Ingress, HPA, PDB
│   ├── values.yaml                # Defaults
│   ├── values-dev.yaml            # Dev overrides
│   └── values-prod.yaml           # Prod overrides
├── k8s/                           # Raw YAML (Kustomize)
│   ├── base/                      # Base manifests
│   └── overlays/
│       ├── dev/                   # Dev patches
│       └── prod/                  # Prod patches
└── src/                           # Spring Boot application source
```

## Prerequisites

- AWS account with permissions for EKS, ECR, VPC, IAM
- GitHub repository with these secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- Terraform >= 1.7, Helm >= 3.14, kubectl
- S3 bucket + DynamoDB table for Terraform remote state

## Quick Start

### 1. Provision Infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### 2. CI/CD Pipeline (automatic)

- Push to `develop` → build → deploy to **dev**
- Push to `main` → build → deploy to **production** (with approval gate)
- Pull request → build + test + Terraform plan

### 3. Manual Deploy with Helm

```bash
aws eks update-kubeconfig --name springboot-eks-dev
helm upgrade --install springboot-app ./helm/springboot-app \
  -f helm/springboot-app/values-dev.yaml \
  --namespace springboot-dev --create-namespace
```

### 4. Manual Deploy with Kustomize

```bash
kubectl apply -k k8s/overlays/dev
```

## Key Features

- **Multi-stage Docker build** with Spring Boot layer extraction for optimized caching
- **Non-root container** with read-only filesystem and dropped capabilities
- **Terraform modules** with KMS encryption, OIDC/IRSA, ECR lifecycle policies
- **Helm chart** with HPA, PDB, pod anti-affinity, startup/liveness/readiness probes
- **Kustomize overlays** as an alternative to Helm for raw YAML workflows
- **Security scanning** via Trivy (filesystem + container image)
- **Atomic deploys** with automatic rollback on failure (production)
- **Prometheus metrics** exposed via Spring Boot Actuator + Micrometer
