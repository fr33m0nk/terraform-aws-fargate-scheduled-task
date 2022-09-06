resource "aws_cloudwatch_event_target" "default" {
  target_id = "${var.name}-target"
  rule      = aws_cloudwatch_event_rule.default.name

  arn      = var.cluster_arn
  role_arn = aws_iam_role.event.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.default.arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = true
    }
  }
}

resource "aws_cloudwatch_event_rule" "default" {
  name                = "${var.name}_schedule"
  tags                = var.tags
  schedule_expression = "cron(${var.cron})"
}

resource "aws_iam_role" "event" {
  name               = "${var.name}_event_role"
  assume_role_policy = data.aws_iam_policy_document.event_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "ecs_run_task" {
  role   = aws_iam_role.event.id
  name   = "ECS_run_task_${var.name}"
  policy = data.aws_iam_policy_document.ecs_run_task.json
}
