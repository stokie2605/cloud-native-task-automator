resource "aws_ecs_cluster" "task_automator" {
  name = "task-automator-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "task-automator-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs_task" {
  name              = "/ecs/task-automator-health-check"
  retention_in_days = 14

  tags = {
    Name = "task-automator-health-check-logs"
  }
}

resource "aws_ecs_task_definition" "health_check" {
  family                   = "task-automator-health-check"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "health-check"
      image     = var.container_image
      essential = true

      environment = [
        {
          name  = "HEALTHCHECK_TARGET_URL"
          value = var.healthcheck_target_url
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "health-check"
        }
      }
    }
  ])

  tags = {
    Name = "task-automator-health-check"
  }
}

resource "aws_cloudwatch_event_rule" "health_check_schedule" {
  name                = "task-automator-health-check-every-12-hours"
  description         = "Runs the cloud-native health check automation task every 12 hours."
  schedule_expression = "rate(12 hours)"
}

resource "aws_cloudwatch_event_target" "health_check_task" {
  rule      = aws_cloudwatch_event_rule.health_check_schedule.name
  target_id = "task-automator-health-check"
  arn       = aws_ecs_cluster.task_automator.arn
  role_arn  = aws_iam_role.eventbridge_ecs_invoke.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.health_check.arn
    task_count          = 1
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = [for subnet in aws_subnet.private : subnet.id]
      security_groups  = [aws_security_group.ecs_task.id]
      assign_public_ip = false
    }
  }
}
