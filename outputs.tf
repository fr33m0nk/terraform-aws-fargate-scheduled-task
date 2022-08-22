output "details" {
  value = {
    aws_ecs_task_definition = aws_ecs_task_definition.default
    aws_cloudwatch_log_group = aws_cloudwatch_log_group.default
    aws_iam_role = aws_iam_role.task
    aws_iam_role_policy_attachment = aws_iam_role_policy_attachment.task_managed
    aws_iam_role_policy = aws_iam_role_policy.task_inline
    ecs_execution_role = module.ecs_execution_role
  }
}
