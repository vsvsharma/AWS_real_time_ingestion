output "firehose_stream_name" {
  description = "The name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.extraction_firehose_stream.name
}

output "firehose_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.extraction_firehose_stream.arn
}