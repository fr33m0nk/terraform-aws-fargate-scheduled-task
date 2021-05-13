resource "aws_ecs_task_definition" "default" {
  family = var.name
  tags   = var.tags

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = local.ecs_role_arn
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
