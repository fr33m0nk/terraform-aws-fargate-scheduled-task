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

  runtime_platform {
    operating_system_family = var.operating_system
    cpu_architecture        = var.cpu_architecture
  }
}

module "ecs_execution_role" {
  source      = "aisamji/ecs-execution-role/aws"
  version     = "1.0.0"
  create_role = var.create_ecs_role
}

resource "aws_cloudwatch_log_group" "default" {
  count = var.create_log_group ? 1 : 0
  name  = local.log_group_name
  tags  = var.tags
}

resource "aws_iam_role" "task" {
  name                  = "${var.name}_task_role"
  assume_role_policy    = data.aws_iam_policy_document.task_assume_role.json
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
  name   = "ECS_custom_task_permissions"
  policy = var.inline_policy_document
}
