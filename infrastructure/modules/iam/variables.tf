#role name for lambda
variable "lambda_role_name" {
  description = "lambda_docker_execution_role"
  type        = string
}

#role name for firehose
variable "firehose_role_name" {
  description = "firehose_execution_role"
  type = string
}

#role name for glue
variable "glue_role_name" {
  description = "glue_execution_role"
  type = string
}