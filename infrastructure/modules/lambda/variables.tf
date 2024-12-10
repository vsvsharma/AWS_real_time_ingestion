variable "function_name" {
  description = "my-docker-lambda"
  type        = string
  default = "user-data-api-extraction"
}

variable "role_arn" {
  description = "IAM Role ARN for Lambda execution"
  type        = string
  # default     = "module.iam.role_arn"
}

variable "image_uri" {
  description = "The URI of the docker image stored in ECR "
  type        = string
}

variable "memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
  default     = "128"
}

variable "timeout" {
  description = "Timeout for the Lambda function"
  type        = number
  default     = "10"
}

variable "event_rule_name" {
  description = "Name of the EventBridge rule"
  type        = string
  default     = "lambda-schedule-rule"
}