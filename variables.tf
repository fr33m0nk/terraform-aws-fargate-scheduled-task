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

variable "create_ecs_role" {
  type        = bool
  description = "A value indicating whether to create an ECS execution role by default."
  default     = false
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

variable "cluster_arn" {
  type        = string
  description = "The ARN of the Fargate cluster where this task should be run."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The task will be launched with an ENI connected to one of the subnets."
}

variable "cron" {
  type        = string
  description = "A valid cron expression. AWS uses UTC time for cron expressions. https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html"
}

variable "command_override" {
  type        = string
  description = "The arguments to pass to the image entrypoint instead of the defaults."
  default     = ""
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security groups that the runner will be a member of."
  default     = []
}

variable "log_group_name" {
  type        = string
  description = "The name of the log group to create/use to stores logs from the task."
  default     = null
}

variable "create_log_group" {
  type        = bool
  description = "A value indicating whether to create the log group or assume that it has been created externally."
  default     = true
}

variable "cpu_architecture" {
  type        = string
  description = "CPU architecture for the task. Must be set to either X86_64 or ARM64"
}
variable "operating_system" {
  type = string
  default = "Must be one of https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform"
}
