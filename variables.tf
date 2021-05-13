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
  description = "The number of CPU units avaialble to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = 256
}

variable "memory" {
  type        = number
  description = "The number of memory units avaialble to this task. See the list of valid configurations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
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
