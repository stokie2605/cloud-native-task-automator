# Cloud-Native Task Automator Walkthrough

This walkthrough is designed for recruiters, hiring managers, and interviewers who want to understand the project quickly without reading every file first.

## Scenario

A technical team needs a repeatable health-check task that can run on a schedule, emit clean logs, and be managed as cloud infrastructure instead of as an ad hoc script on someone's laptop.

This project models that workflow using Python, Docker, Terraform, GitHub Actions, ECS Fargate, EventBridge, IAM, and CloudWatch.

## What Happens When It Runs

1. The Python task reads `HEALTHCHECK_TARGET_URL` or falls back to a default status endpoint.
2. It polls the endpoint with a timeout.
3. It writes JSON-formatted log output to stdout.
4. It returns `0` when the endpoint is healthy.
5. It returns `1` when the endpoint times out, returns an unhealthy HTTP status, or raises a request error.
6. In the AWS design, ECS sends stdout logs to CloudWatch.
7. EventBridge runs the ECS task on a recurring schedule.

## Local Execution Flow

```text
Developer Shell
   |
   v
python task_automator.py
   |
   +--> requests.get(target_url)
   +--> structured JSON log output
   +--> exit code for automation consumers
```

## Cloud Execution Flow

```text
EventBridge Schedule
   |
   v
ECS Fargate Task
   |
   v
Containerized Python Health Check
   |
   v
CloudWatch Logs
```

## CI/CD Flow

```text
Push or Pull Request
   |
   v
GitHub Actions
   |
   +--> Python lint and syntax checks
   +--> Terraform format and validate
   +--> Docker image build
   +--> Trivy image vulnerability scan
```

## Important Files

| File | Why It Matters |
| --- | --- |
| `task_automator.py` | The operational task itself: endpoint polling, logging, and exit-code behavior |
| `Dockerfile` | Shows repeatable packaging and non-root container execution |
| `.github/workflows/ci-cd.yml` | Shows delivery hygiene across Python, Terraform, Docker, and security scanning |
| `terraform/vpc.tf` | Models network isolation for cloud task execution |
| `terraform/iam.tf` | Models least-privilege task and schedule roles |
| `terraform/ecs_schedule.tf` | Connects ECS Fargate, CloudWatch logs, and EventBridge scheduling |

## DevOps Practices Demonstrated

- Treating automation as a deployable workload, not a loose script.
- Using structured logs so task output can be consumed by cloud logging tools.
- Using Terraform to describe infrastructure repeatably.
- Keeping runtime permissions separate from build and scheduling concerns.
- Validating infrastructure and container build quality in CI before deployment.
- Surfacing vulnerability data through Trivy as part of the delivery workflow.

## Production Extension Ideas

- Push the Docker image to Amazon ECR from GitHub Actions.
- Authenticate GitHub Actions to AWS using OIDC.
- Add a manual approval gate before Terraform apply.
- Convert health-check failures into CloudWatch metrics and alarms.
- Route failures to Slack, Teams, PagerDuty, or Jira.
- Add multiple target URLs using a small config file or Parameter Store.
