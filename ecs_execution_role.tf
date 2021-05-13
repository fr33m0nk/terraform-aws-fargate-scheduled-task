data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect  = "Allow"
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

resource "aws_iam_role_policy" "read_secrets" {
  count  = length(var.ecs_role_arn) == 0 ? 1 : 0
  name   = "SecretsReadOnly"
  role   = aws_iam_role.ecs_execution[count.index].id
  policy = data.aws_iam_policy_document.read_secrets.json
}

data "aws_iam_policy_document" "read_secrets" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["kms:Decrypt", "secretsmanager:GetSecretValue"]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
      "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:*"
    ]
  }
}

data "aws_caller_identity" "current" {}
