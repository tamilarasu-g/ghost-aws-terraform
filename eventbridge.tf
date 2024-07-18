resource "aws_cloudwatch_event_rule" "ec2-ghost-stop" {
  name        = "ec2-ghost-stop"
  description = "Trigger the create-volume-start-instance lambda when the instance stops"
  event_pattern = templatefile(var.ec2-ghost-stop-rule-path, {
    instance-id = var.instance-id
  })
}

resource "aws_cloudwatch_event_target" "ec2-ghost-stop-target" {
  rule = aws_cloudwatch_event_rule.ec2-ghost-stop.name
  arn  = aws_lambda_function.snap-and-delete-lambda.arn
}

resource "aws_cloudwatch_event_rule" "ec2-ghost-start" {
  name        = "ec2-ghost-start"
  description = "Trigger the create-a-record lambda when the instance starts"
  event_pattern = templatefile(var.ec2-ghost-start-rule-path, {
    instance-id = var.instance-id
  })
}

resource "aws_cloudwatch_event_target" "ec2-ghost-start-target" {
  rule = aws_cloudwatch_event_rule.ec2-ghost-start.name
  arn  = aws_lambda_function.create-a-record-lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch-ec2-ghost-stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snap-and-delete-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2-ghost-stop.arn
}

resource "aws_lambda_permission" "allow_cloudwatch-ec2-ghost-start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create-a-record-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2-ghost-start.arn
}