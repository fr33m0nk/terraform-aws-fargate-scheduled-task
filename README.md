# terraform-aws-fargate-scheduled-task

## ECS Role ARN

Tasks on ECS require an IAM role to be specified that will allow ECS to pull the docker image from ECR, send logs to CloudWatch, and perform other administrative actions. **THIS IS NOT THE ROLE THAT IS USED BY YOUR TASK TO ACCESS OTHER AWS SERVICES.**

This ECS role must be created as follows:

```terraform
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name = "ECSExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
```

While it is possible to have the module create this role for you, it would be better for you to create this role without this module and pass it in to all modules that need it. This will help to keep your IAM roles decluttered for easy auditing.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 2.24.0 |

## Modules

| Name                                                                                           | Source                         | Version |
|------------------------------------------------------------------------------------------------|--------------------------------|---------|
| <a name="module_ecs_execution_role"></a> [ecs\_execution\_role](#module\_ecs\_execution\_role) | aisamji/ecs-execution-role/aws | 1.0.0   |

## Resources

| Name                                                                                                                                                  | Type        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_cloudwatch_event_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                | resource    |
| [aws_cloudwatch_event_target.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)            | resource    |
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                  | resource    |
| [aws_ecs_task_definition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)                    | resource    |
| [aws_iam_role.event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                             | resource    |
| [aws_iam_role_policy.ecs_run_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                       | resource    |
| [aws_iam_role_policy.task_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                        | resource    |
| [aws_iam_role_policy_attachment.task_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_policy_document.ecs_run_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_iam_policy_document.event_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)       | data source |
| [aws_iam_policy_document.task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)        | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                           | data source |

## Inputs

| Name                                                                                                     | Description                                                                                                                                                                     | Type           | Default | Required |
|----------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn)                                    | The ARN of the Fargate cluster where this task should be run.                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_command_override"></a> [command\_override](#input\_command\_override)                     | The arguments to pass to the image entrypoint instead of the defaults.                                                                                                          | `string`       | `""`    |    no    |
| <a name="input_cpu"></a> [cpu](#input\_cpu)                                                              | The number of CPU units available to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html    | `number`       | `256`   |    no    |
| <a name="input_create_ecs_role"></a> [create\_ecs\_role](#input\_create\_ecs\_role)                      | A value indicating whether to create an ECS execution role by default.                                                                                                          | `bool`         | `false` |    no    |
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group)                   | A value indicating whether to create the log group or assume that it has been created externally.                                                                               | `bool`         | `true`  |    no    |
| <a name="input_cron"></a> [cron](#input\_cron)                                                           | A valid cron expression. AWS uses UTC time for cron expressions. https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html                        | `string`       | n/a     |   yes    |
| <a name="input_ecs_role_arn"></a> [ecs\_role\_arn](#input\_ecs\_role\_arn)                               | The ARN of the role used by ECS to pull the docker image and send logs to CloudWatch. If not specified, the module will create an appropriate role.                             | `string`       | `""`    |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                      | A map of environment variables in 'name = value' format.                                                                                                                        | `map(string)`  | `{}`    |    no    |
| <a name="input_image"></a> [image](#input\_image)                                                        | The image repository and tag in the format <repository>:<tag>.                                                                                                                  | `string`       | n/a     |   yes    |
| <a name="input_inline_policy_document"></a> [inline\_policy\_document](#input\_inline\_policy\_document) | An inline policy document in JSON format to determine additional task permissions.                                                                                              | `string`       | `""`    |    no    |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name)                         | The name of the log group to create/use to stores logs from the task.                                                                                                           | `string`       | `null`  |    no    |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns)          | A list of ARNs for managed policies to determine the task permissions.                                                                                                          | `list(string)` | `[]`    |    no    |
| <a name="input_memory"></a> [memory](#input\_memory)                                                     | The number of memory units available to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number`       | `512`   |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                           | The name that will be used for the resources created.                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_secrets"></a> [secrets](#input\_secrets)                                                  | A map of secret environment variables in 'name = sourceARN' format. Source ARN can reference AWS Secrets Manager or AWS Parameter Store.                                        | `map(string)`  | `{}`    |    no    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)             | A list of security groups that the runner will be a member of.                                                                                                                  | `list(string)` | `[]`    |    no    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                                       | The task will be launched with an ENI connected to one of the subnets.                                                                                                          | `list(string)` | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                           | The tags to apply to all created resources.                                                                                                                                     | `map(string)`  | `{}`    |    no    |
| <a name="input_cpu_architecture"></a> [cpu_architecture](#input\_tags)                                   | CPU architecture for the task. Must be set to either X86_64 or ARM64.                                                                                                           | `string`       | `n/a`   |   yes    |
| <a name="input_operating_system"></a> [operating_system](#input\_tags)                                   | Must be one of [these](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform).                                           | `string`       | `n/a`   |   yes    |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
