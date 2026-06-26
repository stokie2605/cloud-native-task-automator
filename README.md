# Cloud-Native Task Automator

An intermediate-level engineering project focused on Infrastructure as Code (IaC), automated cloud provisioning, and secure scheduled task execution.

## 🏗️ Architecture Overview
*Currently in Phase 2: Core Automation Script & Local Containerization*

The objective of this project is to use **Terraform** to declare and provision a fully isolated cloud environment that runs a containerized automation script on a native cron schedule.

### Planned Target Stack:
- **Infrastructure:** AWS (VPC, IAM Least-Privilege Roles, ECS Fargate or AWS Lambda)
- **Provisioning Tool:** Terraform
- **Automation Logic:** Python / Node.js
- **CI/CD & Governance:** GitHub Actions (with security linting)

---

## 🧪 Current Automation Utility

The current implementation includes a Python infrastructure health check script that polls an external health endpoint and emits structured JSON logs suitable for CI/CD, container logs, and future cloud scheduler output.

### Files Added in Phase 2
- `app.py` - modular Python health check utility using `requests`.
- `requirements.txt` - pinned Python dependency list.
- `Dockerfile` - secure multi-stage Python 3.11 container build running as a non-root user.

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

---

## 🛠️ Step-by-Step Implementation Log

### 🟦 Phase 1: Repository Initialization & Architecture Mapping
- [x] Created clean repository structure.
- [x] Defined target cloud architecture and security principles.

### 🟦 Phase 2: Writing the core automation script and local Dockerfile.
- [x] Implemented modular Python health check utility with structured JSON logging.
- [x] Hardened container environment by enforcing a non-root user policy inside the Dockerfile.

### ⬜ Phase 3: Writing the Terraform configuration modules.
- [ ] Define provider configuration and remote-state strategy.
- [ ] Build network, IAM, and scheduled execution modules.

### ⬜ Phase 4: Constructing the secure GitHub Actions deployment pipeline.
- [ ] Add CI checks for Python syntax, dependency installation, and container build validation.
- [ ] Add security linting for Docker and Terraform artifacts.
