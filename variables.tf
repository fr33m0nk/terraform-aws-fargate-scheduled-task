variable "name" {
  type        = string
  description = "The name that will be used for the resources created."
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to all created resources."
  default     = {}
}

variable "cpu" {
  type        = number
  description = "The number of CPU units available to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = 256
}

variable "memory" {
  type        = number
  description = "The number of memory units available to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = 512
}

variable "ecs_role_arn" {
  type        = string
  description = "The ARN of the role used by ECS to pull the docker image and send logs to CloudWatch. If not specified, the module will create an appropriate role."
  default     = ""
}

variable "image" {
  type        = string
  description = "The image repository and tag in the format <repository>:<tag>."
}

variable "environment" {
  type        = map(string)
  description = "A map of environment variables in 'name = value' format."
  default     = {}
}

variable "secrets" {
  type        = map(string)
  description = "A map of secret environment variables in 'name = sourceARN' format. Source ARN can reference AWS Secrets Manager or AWS Parameter Store."
  default     = {}
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "A list of ARNs for managed policies to determine the task permissions."
  default     = []
}

variable "inline_policy_document" {
  type        = string
  description = "An inline policy document in JSON format to determine additional task permissions."
  default     = ""
}

variable "cluster_id" {
  type        = string
  description = "The ID of the Fargate cluster where this task should be run."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The task will be launched with an ENI connected to one of the subnets."
}

variable "cron" {
  type        = string
  description = "A valid cron expression. `rate` expressions are not supported. https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html"
}
