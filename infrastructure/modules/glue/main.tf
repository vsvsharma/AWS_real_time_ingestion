# glue catalog database

resource "aws_glue_catalog_database" "databases" {
  for_each = var.databases
  name = each.key
}

resource "aws_glue_catalog_table" "glue_tables" {
  for_each = { for table in var.tables : table.name => table }

  name          = each.value.name
  database_name = each.value.database
  description   = each.value.comment
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location = each.value.location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    dynamic "columns" {
      for_each = each.value.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }
    parameters = {
      "classification" = "parquet"
    }
  dynamic "partition_keys" {
    for_each = each.value.partition_keys
    content {
      name = partition_keys.value.name
      type = partition_keys.value.type
    }
  }
}


resource "aws_glue_crawler" "raw_data_layer_crawler" {
  for_each = var.crawlers
  name=each.value.name
  role = each.value.role_arn
  database_name = each.value.database_name
    s3_target{
      path=each.value.s3_target
    }
  schedule = each.value.schedule
}


resource "aws_glue_job" "transformation_script" {
  name = "transformation_glue_job.py"
  role_arn = var.glue_job_role_arn
  command {
    name = "glueetl"
    script_location ="s3://transformation-script-glue-job-bucket/transformation_glue_job.py"
    python_version = "3"
    }
  default_arguments = {
    "--enable-continous-cloudwatch-log"="true"
    }

  max_retries = 1
  glue_version = "4.0"
  number_of_workers = 2
  worker_type = "G.1X"
}

# resource "aws_glue_trigger" "glue_job_trigger" {
#   name = "glue_job_trigger"
#   type = "CONDITIONAL"

#   actions {
#     job_name = aws_glue_job.transformation_script.name
#   }

#   predicate {
#     conditions {
#       logical_operator = "EQUALS"
#       crawler_name = aws_glue_crawler.raw_data_layer_crawler["raw_layer_crawler"].name
#       crawl_state  = "SUCCEEDED"
#     }
#   }
# }

resource "aws_glue_trigger" "glue_job_trigger" {
  name = "glue_job_daily_trigger"
  type = "SCHEDULED"
  description = "Trigger daily at 1:30AM"

  schedule = "cron(30 1 * * ? *)" # Daily at 1:30 AM UTC

  actions {
    job_name = aws_glue_job.transformation_script.name
  }
}





