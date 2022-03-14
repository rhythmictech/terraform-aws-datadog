resource "aws_cloudwatch_event_rule" "guardduty" {
  count = var.enable_guardduty_notifications ? 1 : 0

  name_prefix = substr("gd-finding-${var.name}", 0, 35)
  description = "Match on GuardDuty alert (Datadog)"

  event_pattern = <<EOT
{
  "detail-type": [
    "GuardDuty Finding"
  ],
  "source": [
    "aws.guardduty"
  ]
}
EOT
}

resource "aws_cloudwatch_event_target" "guardduty" {
  count = var.enable_guardduty_notifications ? 1 : 0

  arn       = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  rule      = aws_cloudwatch_event_rule.guardduty[0].name
  target_id = "send-to-datadog"
}

resource "aws_lambda_permission" "guardduty_trigger" {
  count = var.enable_guardduty_notifications ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty[0].arn
  statement_id  = "GuardDutyTrigger"
}
