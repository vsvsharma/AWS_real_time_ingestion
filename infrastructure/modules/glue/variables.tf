variable "databases" {
  type = set(string)
}

variable "tables" {
  type = list(object({
    name          = string
    location      = string
    columns       = list(object({
      name = string
      type = string
    }))
    comment       = string
    database      = string
    partition_keys = list(object({
      name = string
      type = string
    }))
  }))
}

variable "crawlers" {
  type = map(object({
    name          = string
    role_arn      = string
    database_name = string
    s3_target     = string
    schedule      = string
  }))
}

variable "glue_job_role_arn" {
  description = "Role for the glue job execution"
  type = string
}


