#output for the lambda role arn
output "lambda_role_arn" {
  description = "IAM Lambda Role ARN"
  value       = aws_iam_role.lambda_role.arn
}

#output for firehose role arn
output "firehose_role_arn" {
  description = "IAM firehose role ARN"
  value = aws_iam_role.firehose_role.arn
}

#output for the Glue role arn
output "glue_role_arn" {
  description = "IAM glue role ARN"
  value = aws_iam_role.glue_role.arn
}

#output for the glue job arn
output "glue_job_role_arn" {
  description = "IAM role for the glue job"
  value = aws_iam_role.glue_job_role.arn
}