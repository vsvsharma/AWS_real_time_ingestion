variable "firehose_name" {
  description = "The name of the Kinesis Firehose delivery stream"
  type        = string
  default     = "user-data-ingestion-stream"
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
  default = "aws_s3_bucket.firehose_bucket.arn"
}

variable "kinesis_firehose_role" {
  description = "ARN of the IAM Role for firehose"
  type = string
}

variable "buffering_size" {
  description = "The size (in MBs) of the buffer before Firehose writes to S3"
  type        = number
  default     = 64
}

variable "buffering_interval" {
  description = "The time (in seconds) before Firehose writes to S3"
  type        = number
  default     = 300
}

variable "glue_database_name" {
  description = "The name of the glue database"
  type = string
}

variable "glue_table_name" {
  description = "The name of the Glue table"
  type = string
}


