# Lambda function using Docker image from ECR
resource "aws_lambda_function" "docker_lambda" {
  function_name = var.function_name
  role          = var.role_arn
  image_uri     = var.image_uri
  package_type = "Image"
  memory_size  = var.memory_size
  timeout      = var.timeout
}

resource "aws_lambda_permission" "allow_invocation" {
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}

# EventBridge rule to trigger Lambda every 1 minute
resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  name                = var.event_rule_name
  description         = "EventBridge rule to trigger Lambda every 1 minute"
  schedule_expression = "rate(1 minute)"
}

# Target to invoke Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule.name
  arn       = aws_lambda_function.docker_lambda.arn
}

# Attach the EventBridge rule to the Lambda function
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}