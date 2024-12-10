output "s3_bucket_arn" {
  description = "ARN of the bucket where firehose delivers the data"
  value = aws_s3_bucket.firehose_bucket.arn
}

output "s3_bucket_name" {
  description = "name of the bucket where firehose delivers the data"
  value = aws_s3_bucket.firehose_bucket.bucket
}

output "transform_layer_bucket" {
  description = "name of the transform layer bucket"
  value = aws_s3_bucket.transform_bucket.bucket
}