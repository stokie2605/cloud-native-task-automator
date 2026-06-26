# Cloud-Native Task Automator

An intermediate-level engineering project focused on Infrastructure as Code (IaC), automated cloud provisioning, and secure scheduled task execution.

## 🏗️ Architecture Overview
*Currently in Phase 4: CI/CD Validation Pipeline Added*

The objective of this project is to use **Terraform** to declare and provision a fully isolated cloud environment that runs a containerized automation script on a native cron schedule.

### Planned Target Stack:
- **Infrastructure:** AWS (VPC, IAM Least-Privilege Roles, ECS Fargate)
- **Provisioning Tool:** Terraform
- **Automation Logic:** Python containerized with Docker
- **CI/CD & Governance:** GitHub Actions (with security linting)

---

## 🧪 Current Automation Utility

The current implementation includes a Python infrastructure health check script that polls an external health endpoint and emits structured JSON logs suitable for CI/CD, container logs, and future cloud scheduler output.

### Files Added in Phase 2
- `app.py` - modular Python health check utility using `requests`.
- `requirements.txt` - pinned Python dependency list.
- `Dockerfile` - secure multi-stage Python 3.11 container build running as a non-root user.

### Files Added in Phase 3
- `terraform/providers.tf` - AWS provider and Terraform version constraints.
- `terraform/variables.tf` - configurable region, environment, image URI, and health check target URL.
- `terraform/vpc.tf` - multi-AZ VPC, public/private subnets, NAT gateways, routing, and outbound-only ECS task security group.
- `terraform/iam.tf` - least-privilege ECS task execution, task runtime, and EventBridge invoke roles.
- `terraform/ecs_schedule.tf` - ECS Fargate cluster, task definition, CloudWatch logging, and EventBridge schedule running every 12 hours.

### Files Added in Phase 4
- `.github/workflows/ci-cd.yml` - GitHub Actions workflow for Python linting, Terraform validation, Docker build verification, and Trivy image scanning.

### Local Run

```bash
pip install -r requirements.txt
python app.py
```

Override the default target endpoint:

```bash
HEALTHCHECK_TARGET_URL=https://example.com/health python app.py
```

### Docker Run

```bash
docker build -t cloud-native-task-automator .
docker run --rm cloud-native-task-automator
```

### Terraform Plan

```bash
cd terraform
terraform init
terraform plan
```

Replace `container_image` with a real ECR image URI before applying the scheduled ECS task in AWS.

---

## 🛠️ Step-by-Step Implementation Log

### 🟦 Phase 1: Repository Initialization & Architecture Mapping
- [x] Created clean repository structure.
- [x] Defined target cloud architecture and security principles.

### 🟦 Phase 2: Writing the core automation script and local Dockerfile.
- [x] Implemented modular Python health check utility with structured JSON logging.
- [x] Hardened container environment by enforcing a non-root user policy inside the Dockerfile.

### 🟦 Phase 3: Writing the Terraform configuration modules.
- [x] Declared multi-AZ VPC architecture with public/private subnet isolation.
- [x] Enforced IAM least-privilege task execution roles for cloud compute containment.
- [x] Provisioned ECS Fargate task definitions linked to an EventBridge cron schedule for serverless execution.

### 🟦 Phase 4: Constructing the secure GitHub Actions deployment pipeline.
- [x] Added CI checks for Python syntax, dependency installation, and flake8 linting.
- [x] Added Terraform format and validation checks using `terraform init -backend=false`.
- [x] Added Docker build validation and Trivy vulnerability scanning for the built image.

## Remaining Production Work

- Replace the placeholder `container_image` variable with a real ECR image URI.
- Add an ECR repository and authenticated image push workflow.
- Add AWS OIDC federation for GitHub Actions instead of long-lived credentials.
- Add a gated Terraform plan/apply workflow for real AWS deployment.
