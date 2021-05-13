data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  count              = length(var.ecs_role_arn) == 0 ? 1 : 0
  name               = "${var.name}ECSExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  count      = length(var.ecs_role_arn) == 0 ? 1 : 0
  role       = aws_iam_role.ecs_execution[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  ecs_role_arn = compact(concat([var.ecs_role_arn], aws_iam_role.ecs_execution.*.arn))[0]
}
