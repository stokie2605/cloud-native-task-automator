data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "task-automator-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name               = "task-automator-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_runtime" {
  statement {
    sid    = "AllowWriteHealthCheckLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.ecs_task.arn}:*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_runtime" {
  name   = "task-automator-runtime-policy"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_runtime.json
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eventbridge_ecs_invoke" {
  name               = "task-automator-eventbridge-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

data "aws_iam_policy_document" "eventbridge_ecs_invoke" {
  statement {
    sid    = "AllowRunScheduledTask"
    effect = "Allow"

    actions   = ["ecs:RunTask"]
    resources = [aws_ecs_task_definition.health_check.arn]

    condition {
      test     = "ArnLike"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.task_automator.arn]
    }
  }

  statement {
    sid    = "AllowPassTaskRoles"
    effect = "Allow"

    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.ecs_task_execution.arn,
      aws_iam_role.ecs_task.arn
    ]
  }
}

resource "aws_iam_role_policy" "eventbridge_ecs_invoke" {
  name   = "task-automator-eventbridge-ecs-policy"
  role   = aws_iam_role.eventbridge_ecs_invoke.id
  policy = data.aws_iam_policy_document.eventbridge_ecs_invoke.json
}
