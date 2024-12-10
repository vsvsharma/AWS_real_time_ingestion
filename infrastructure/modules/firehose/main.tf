resource "aws_kinesis_firehose_delivery_stream" "extraction_firehose_stream" {
  name        = var.firehose_name
  destination = "extended_s3"

   extended_s3_configuration {
    role_arn           = var.kinesis_firehose_role
    bucket_arn         = var.s3_bucket_arn
    buffering_size = var.buffering_size
    buffering_interval = var.buffering_interval
    compression_format = "UNCOMPRESSED"

    #data format conversion i.e. parquet
    data_format_conversion_configuration {
      enabled = true
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        role_arn = var.kinesis_firehose_role
        database_name = var.glue_database_name
        table_name = var.glue_table_name
        version_id = "LATEST"
      }
    }

    # Inline JSON parsing using Processing Configuration
    processing_configuration {
      enabled = true

        processors {
        type = "MetadataExtraction"

        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{ p_date: .p_date }"


        }
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
      }
    }

    #Dynamic Partitioning
    dynamic_partitioning_configuration {
      enabled = "true"
      retry_duration = 300
    }
    prefix = "!{partitionKeyFromQuery:p_date}/"
    error_output_prefix = "error/!{firehose:error-output-type}/"

    #enabling cloudwatch logs
    cloudwatch_logging_options {
      enabled = true
      log_group_name = "/aws/kinesisfirehose/user-data-ingestion-stream"
      log_stream_name = "delivery-stream-logs"
    }
  }
  
}

