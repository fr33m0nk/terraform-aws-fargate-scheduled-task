resource "aws_ecs_task_definition" "default" {
  family = var.name
  tags   = var.tags

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = local.ecs_role_arn
  task_role_arn            = aws_iam_role.task.arn
  network_mode             = "awsvpc"
  container_definitions    = jsonencode(local.container_definitions)
}

locals {
  ecs_role_arn = length(var.ecs_role_arn) == 0 ? module.ecs_execution_role.ecs_role_arn : var.ecs_role_arn
  container_definitions = [
    {
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
          awslogs-group         = aws_cloudwatch_log_group.default.name
          awslogs-stream-prefix = "cron"
        }
      }
    }
  ]
}

module "ecs_execution_role" {
  source      = "aisamji/ecs-execution-role/aws"
  version     = "1.0.0"
  create_role = length(var.ecs_role_arn) == 0
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "default" {
  name = "/aws/ecs/${var.name}"
  tags = var.tags
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
