resource "aws_cloudwatch_event_rule" "awshealth" {
  count = var.enable_health_notifications ? 1 : 0

  name_prefix = substr("awshealth-event-${var.name}", 0, 35)
  description = "Match on AWS Health alert (Datadog)"

  event_pattern = <<EOT
{
  "detail-type": [
    "AWS Health Event"
  ],
  "source": [
    "aws.health"
  ]
}
EOT
}

resource "aws_cloudwatch_event_target" "awshealth" {
  count = var.enable_health_notifications ? 1 : 0

  arn       = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  rule      = aws_cloudwatch_event_rule.awshealth[0].name
  target_id = "send-to-datadog"
}

resource "aws_lambda_permission" "awshealth_trigger" {
  count = var.enable_health_notifications ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.awshealth[0].arn
  statement_id  = "AWSHealthTrigger"
}

resource "datadog_logs_custom_pipeline" "health" {
  count = var.enable_health_notifications ? 1 : 0

  filter {
    query = "source:health"
  }
  name       = "AWS Health"
  is_enabled = true

  processor {
    message_remapper {
      is_enabled = true
      name       = "Define `detail.eventDescription.latestDescription` as the message"
      sources = [
        "detail.eventDescription.latestDescription",
      ]
    }
  }
  processor {
    attribute_remapper {
      is_enabled           = true
      name                 = "Map `detail.eventDescription.eventTypeCode` to event.name"
      override_on_conflict = false
      preserve_source      = true
      source_type          = "attribute"
      sources = [
        "detail.eventDescription.eventTypeCode",
      ]
      target      = "evt.name"
      target_type = "attribute"
    }
  }
  processor {
    attribute_remapper {
      is_enabled           = true
      name                 = "Map `detail.eventScopeCode` to tag `scope`"
      override_on_conflict = false
      preserve_source      = true
      source_type          = "attribute"
      sources = [
        "detail.eventScopeCode",
      ]
      target      = "scope"
      target_type = "tag"
    }
  }

}
