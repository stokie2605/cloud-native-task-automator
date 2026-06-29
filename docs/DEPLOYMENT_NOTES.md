# Deployment Notes

This repository demonstrates a scheduled ECS/Fargate task pattern. It is structured so reviewers can validate the app locally without deploying AWS resources, then understand what would be needed for a real account.

## Runtime Flow

```text
EventBridge Schedule
  -> ECS Fargate Task Definition
  -> Containerized Python Health Check
  -> Structured JSON Logs
  -> CloudWatch Log Group
```

## Local Dry Run

```bash
pip install -r requirements.txt
HEALTHCHECK_TARGET_URL=https://www.githubstatus.com/api/v2/status.json python task_automator.py
```

A sample log event is available at `docs/sample-task-output.json`.

## Configuration

Use `.env.example` as the reviewer-safe template for local values. Do not commit real AWS account identifiers, ECR image URIs, or secrets.

## Production Extensions

- Push the built image to ECR.
- Configure GitHub OIDC for AWS deploy credentials.
- Run Terraform plan/apply through a protected deployment workflow.
- Emit CloudWatch metrics or alerts on failed health checks.
