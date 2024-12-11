/*
declaring the required variable namaes for the resources created
*/
variable "s3_bucket_name" {
  description = "user-data-raw-layer"
  type = string
}

variable "s3_transform_bucket" {
  description = "user-data-transform-layer"
  type = string
}

variable "glue_job_bucket" {
  description = "bucket for storing glue job"
  type = string
}