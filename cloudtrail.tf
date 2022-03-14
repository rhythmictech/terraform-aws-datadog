resource "aws_lambda_permission" "cloudtrail_trigger" {
  for_each = toset(var.cloudtrail_buckets)

  action        = "lambda:InvokeFunction"
  function_name = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value}"
  statement_id  = "CloudTrailTrigger"
}

resource "aws_s3_bucket_notification" "cloudtrail_notification" {
  for_each = toset(var.cloudtrail_buckets)

  bucket = each.value

  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  }
}
