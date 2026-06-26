variable "aws_region" {
  description = "AWS region used for all provisioned resources."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment label applied to provisioned resources."
  type        = string
  default     = "dev"
}

variable "container_image" {
  description = "Container image URI for the scheduled automation task. Replace with an ECR image after the CI/CD pipeline publishes one."
  type        = string
  default     = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/cloud-native-task-automator:latest"
}

variable "healthcheck_target_url" {
  description = "External endpoint polled by the health check container."
  type        = string
  default     = "https://www.githubstatus.com/api/v2/status.json"
}
