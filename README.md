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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_task_definition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.ecs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of CPU units avaialble to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `256` | no |
| <a name="input_ecs_role_arn"></a> [ecs\_role\_arn](#input\_ecs\_role\_arn) | The ARN of the role used by ECS to pull the docker image and send logs to CloudWatch. If not specified, the module will create an appropriate role. | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | A map of environment variables in 'name = value' format. | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | The image repository and tag in the format <repository>:<tag>. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The number of memory units avaialble to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | The name that will be used for the resources created. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map of secret environment variables in 'name = sourceARN' format. Source ARN can reference AWS Secrets Manager or AWS Parameter Store. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to all created resources. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
