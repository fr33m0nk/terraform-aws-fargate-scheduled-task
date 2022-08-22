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

  log_group_name = coalesce(var.log_group_name, "/aws/ecs/${var.name}")
}
