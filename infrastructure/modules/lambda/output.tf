output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.docker_lambda.arn
}

output "event_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}
