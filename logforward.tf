resource "aws_cloudformation_stack" "datadog_forwarder" {
  count = var.install_log_forwarder ? 1 : 0

  name         = "${var.name}-log-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"

  parameters = {
    DdApiKeySecretArn = aws_secretsmanager_secret.datadog.arn,
    DdSite            = var.datadog_site_name,
    FunctionName      = "${var.name}-forwarder"
  }

  depends_on = [datadog_integration_aws.datadog]
}

resource "datadog_integration_aws_lambda_arn" "datadog_forwarder" {
  count      = var.install_log_forwarder ? 1 : 0
  account_id = local.account_id
  lambda_arn = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")

  depends_on = [aws_cloudformation_stack.datadog_forwarder]
}

resource "time_sleep" "wait_datadog_forwarder" {
  create_duration = "30s"

  depends_on = [datadog_integration_aws_lambda_arn.datadog_forwarder]
}

resource "datadog_integration_aws_log_collection" "datadog_forwarder" {
  count      = var.install_log_forwarder ? 1 : 0
  account_id = local.account_id
  services   = var.log_forwarder_sources

  depends_on = [time_sleep.wait_datadog_forwarder]
}

resource "aws_lambda_permission" "bucket_trigger" {
  for_each = toset(var.forward_buckets)

  action        = "lambda:InvokeFunction"
  function_name = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value}"
  statement_id  = "${substr(replace(each.value, "/", "_"), 0, 67)}-AllowExecutionFromS3"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = toset(var.forward_buckets)

  bucket = each.value

  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  }
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs" {
  for_each = toset(var.forward_log_groups)

  name            = "${each.value}-filter"
  filter_pattern  = ""
  destination_arn = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  distribution    = "Random"
  log_group_name  = each.value
}

resource "aws_lambda_permission" "cloudwatch_logs" {
  for_each = toset(var.forward_log_groups)

  statement_id  = "${substr(replace(each.value, "/", "_"), 0, 67)}-AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:${each.value}:*"
}
