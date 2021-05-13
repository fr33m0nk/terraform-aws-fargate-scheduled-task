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
          awslogs-stream-prefix = "fargate"
        }
      }
    }
  ]
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "default" {
  name = "/aws/ecs/"
  tags = var.tags
}

resource "aws_iam_role" "task" {
  name                  = "${var.name}TaskRole"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role.json
  force_detach_policies = true
  tags                  = var.tags
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
