output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}
output "extraction_image_uri" {
  description = "ECR repository URL"
  value       = "${module.ecr.repository_url}:latest"
}
output "lambda_role_arn" {
  description = "Docker Lambda IAM Role ARN"
  value       = module.iam.lambda_role_arn
}

output "firehose_role_arn" {
  description = "Firehose IAM Role ARN"
  value       = module.iam.firehose_role_arn
}

output "firehose_s3_buket_arn" {
  description = "Firehose IAM Role ARN"
  value       = module.s3.s3_bucket_arn
}