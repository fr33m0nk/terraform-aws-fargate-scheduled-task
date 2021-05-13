resource "aws_cloudwatch_event_target" "default" {
  target_id = "${var.name}-target"
  rule      = aws_cloudwatch_event_rule.default.name

  arn      = var.cluster_id
  role_arn = aws_iam_role.event.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.default.arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = var.subnet_ids
      assign_public_ip = true
    }
  }
}

resource "aws_cloudwatch_event_rule" "default" {
  name                = "${var.name}Schedule"
  tags                = var.tags
  schedule_expression = "cron(${var.cron})"
}

resource "aws_iam_role" "event" {
  name               = "${var.name}EventRole"
  assume_role_policy = data.aws_iam_policy_document.event_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "event_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_run_task" {
  role   = aws_iam_role.event.id
  name   = "ECSRunTask${var.name}"
  policy = data.aws_iam_policy_document.ecs_run_task.json
}

data "aws_iam_policy_document" "ecs_run_task" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = [replace(aws_ecs_task_definition.default.arn, "/:\\d+$/", ":*")]
  }
}
