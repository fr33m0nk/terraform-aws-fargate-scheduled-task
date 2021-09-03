resource "aws_ecs_task_definition" "default" {
  family = var.name
  tags   = var.tags

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = local.ecs_role_arn
  task_role_arn            = aws_iam_role.task.arn
  network_mode             = "awsvpc"
  container_definitions    = jsonencode([local.merged_container_definition])
}

locals {
  ecs_role_arn = var.create_ecs_role ? module.ecs_execution_role.ecs_role_arn : var.ecs_role_arn

  base_container_definition = {
    name        = var.name
    essential   = true
    image       = var.image
    cpu         = var.cpu
    memory      = var.memory
    environment = [for k, v in var.environment : { name = k, value = v }]
    secrets     = [for k, arn in var.secrets : { name = k, valueFrom = arn }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = data.aws_region.current.name
        awslogs-group         = local.log_group_name
        awslogs-stream-prefix = "cron"
      }
    }
  }

  command_override_definition = length(var.command_override) == 0 ? {} : {
    command = split(" ", var.command_override)
  }

  merged_container_definition = merge(
    local.base_container_definition,
    local.command_override_definition
  )
}

module "ecs_execution_role" {
  source      = "aisamji/ecs-execution-role/aws"
  version     = "1.0.0"
  create_role = var.create_ecs_role
}

data "aws_region" "current" {}

locals {
  log_group_name = coalesce(var.log_group_name, "/aws/ecs/${var.name}")
}

resource "aws_cloudwatch_log_group" "default" {
  count = var.create_log_group ? 1 : 0
  name  = local.log_group_name
  tags  = var.tags
}

resource "aws_iam_role" "task" {
  name                  = "${var.name}TaskRole"
  assume_role_policy    = data.aws_iam_policy_document.task_assume_role.json
  force_detach_policies = true
  tags                  = var.tags
}

data "aws_iam_policy_document" "task_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_managed" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = var.managed_policy_arns[count.index]
}

resource "aws_iam_role_policy" "task_inline" {
  count  = length(var.inline_policy_document) == 0 ? 0 : 1
  role   = aws_iam_role.task.id
  name   = "CustomTaskPermissions"
  policy = var.inline_policy_document
}
