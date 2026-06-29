[![CI/CD Quality Gate](https://github.com/stokie2605/cloud-native-task-automator/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/stokie2605/cloud-native-task-automator/actions/workflows/ci-cd.yml)

# Cloud-Native Task Automator

Cloud-Native Task Automator is a DevOps portfolio project that provisions the AWS infrastructure for a scheduled containerized health-check task. It combines Python automation, Docker, Terraform, ECS Fargate, EventBridge scheduling, IAM least privilege, and GitHub Actions validation into one cloud-native workflow.

The project demonstrates how a small operational script can be packaged, validated, scanned, and prepared for scheduled execution in AWS.

## Recruiter Snapshot

| Area | What This Project Shows |
| --- | --- |
| Automation | Python health-check utility with structured JSON logs and configurable target endpoint |
| Containers | Multi-stage Docker build, slim runtime image, dependency isolation, non-root execution |
| Infrastructure as Code | Terraform-defined AWS provider, VPC, IAM roles, ECS task, CloudWatch logs, and EventBridge schedule |
| CI/CD | GitHub Actions quality gate for Python linting, Terraform validation, Docker build, and Trivy scanning |
| Cloud Operations | Scheduled serverless task pattern suitable for uptime checks, internal probes, and operational evidence |

## Problem

Operational teams often need small recurring checks: poll a health endpoint, verify an internal service, emit logs, and fail clearly when something is wrong. Running those checks manually is inconsistent, and running them from a workstation creates weak auditability.

## Solution

This repository turns a Python health-check script into a cloud-native scheduled task pattern:

```mermaid
flowchart TD
    Commit([Code Commit]) --> GHA{GitHub Actions Quality Gate}
    
    subgraph CI [Continuous Integration]
        GHA --> Py[Python Syntax & Lint]
        GHA --> TF[Terraform Validate]
        GHA --> Doc[Docker Build Verification]
        GHA --> Sec[Trivy Image Scan]
    end
    
    Doc --> Img[Docker Image Pattern]
    TF --> Infra[Terraform Infrastructure]
    
    subgraph AWS [AWS Cloud Infrastructure]
        EB([EventBridge Schedule]) -->|Triggers| ECS[ECS Fargate Task]
        ECS -->|Outputs to| CW[(CloudWatch Logs)]
    end
    
    Img -.->|Runs as| ECS
    Infra -->|Provisions| AWS
```

## Architecture

The Terraform configuration models a deployable AWS runtime:

- VPC with public/private subnet structure.
- ECS Fargate cluster and task definition.
- CloudWatch log group for task output.
- EventBridge schedule that runs the task every 12 hours.
- IAM execution, runtime, and schedule invocation roles using least-privilege boundaries.
- Configurable health-check target URL and container image URI.

## DevOps Skills Demonstrated

- Built a Python CLI-style automation task with clean exit codes and JSON-formatted logs.
- Containerized the script with a multi-stage Dockerfile and non-root runtime user.
- Declared AWS infrastructure with Terraform instead of manual console setup.
- Added GitHub Actions checks for Python, Terraform, Docker, and image vulnerability scanning.
- Used Trivy in report-only mode to surface base-image findings without blocking portfolio iteration.
- Documented the path from local script to scheduled ECS Fargate workload.

## Key Files

| File | Purpose |
| --- | --- |
| `task_automator.py` | Python health-check task with structured logging and clear success/failure exit codes |
| `requirements.txt` | Pinned Python dependencies for local and container execution |
| `Dockerfile` | Multi-stage Python 3.11 image build with non-root runtime user |
| `.github/workflows/ci-cd.yml` | CI/CD quality gate for linting, Terraform validation, Docker build, and Trivy scan |
| `terraform/providers.tf` | Terraform and AWS provider constraints |
| `terraform/variables.tf` | Configurable AWS region, environment, container image, and health-check target URL |
| `terraform/vpc.tf` | Isolated networking foundation for ECS task execution |
| `terraform/iam.tf` | IAM roles for ECS execution, task runtime, and scheduled invocation |
| `terraform/ecs_schedule.tf` | ECS Fargate task, CloudWatch logging, and EventBridge schedule |
| `docs/walkthrough.md` | Guided reviewer walkthrough for interview or portfolio review |

## Local Run

Install dependencies and run the health check locally:

```bash
pip install -r requirements.txt
python task_automator.py
```

Override the default target endpoint:

```bash
HEALTHCHECK_TARGET_URL=https://example.com/health python task_automator.py
```

## Docker Run

Build and run the containerized task:

```bash
docker build -t cloud-native-task-automator .
docker run --rm cloud-native-task-automator
```

Run against a custom endpoint:

```bash
docker run --rm \
  -e HEALTHCHECK_TARGET_URL=https://example.com/health \
  cloud-native-task-automator
```

## Terraform Validation

Validate the infrastructure configuration without creating AWS resources:

```bash
cd terraform
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform plan
```

Before applying in a real AWS account, replace `container_image` with an ECR image URI that points to a published image.

## CI/CD Quality Gate

The GitHub Actions workflow runs on pushes and pull requests to `main`:

- Python dependency installation and flake8 syntax checks.
- Terraform formatting and validation.
- Docker Buildx image build verification.
- Trivy scan for `CRITICAL` and `HIGH` image vulnerabilities.

## Production Extension Path

Next production-grade additions would be:

- Add an ECR repository and authenticated image push workflow.
- Add AWS OIDC federation for GitHub Actions instead of long-lived credentials.
- Add a gated Terraform plan/apply workflow for controlled infrastructure changes.
- Store health-check results in CloudWatch metrics or a lightweight datastore.
- Send failures into Slack, Teams, PagerDuty, or ticketing workflows.
- Move Trivy from report-only to blocking mode once the accepted CVE baseline is defined.

## Reviewer Notes

- Environment template: [.env.example](.env.example)
- Sample task log: [docs/sample-task-output.json](docs/sample-task-output.json)
- Deployment notes: [docs/DEPLOYMENT_NOTES.md](docs/DEPLOYMENT_NOTES.md)
