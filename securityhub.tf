resource "aws_cloudwatch_event_rule" "securityhub_to_datadog" {
  count = var.enable_securityhub_notifications ? 1 : 0

  name_prefix = substr("securityhub-finding-${var.name}", 0, 35)
  description = "Match on SecurityHub findings (Datadog)"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
  })
}

resource "aws_cloudwatch_event_target" "securityhub_to_datadog" {
  count = var.enable_securityhub_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.securityhub_to_datadog[0].name
  target_id = "SendToDatadogLogForwarder"
  arn       = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")

  input_transformer {
    input_paths = {
      detail = "$.detail"
    }
    input_template = <<EOF
{
  "detail-type": "Security Hub Findings - Imported",
  "source": "aws.securityhub",
  "detail": <detail>
}
EOF
  }
}

resource "aws_lambda_permission" "securityhub_trigger" {
  count = var.enable_securityhub_notifications ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.securityhub_to_datadog[0].arn
  statement_id  = "SecurityHubTrigger"
}
