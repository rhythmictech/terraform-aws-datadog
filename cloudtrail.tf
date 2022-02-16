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

# data "aws_iam_policy_document" "cloudtrail" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${var.datadog_account_id}:root"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "sts:ExternalId"
#       values   = [datadog_integration_aws.datadog.external_id]
#     }
#   }
# }

# resource "aws_iam_policy" "cloudtrail" {
#   name_prefix = "${var.name}-CloudTrail"
#   path        = "/"
#   policy      = data.aws_iam_policy_document.json
#   tags        = local.tags
# }

# resource "aws_iam_role_policy_attachment" "cloudtrail" {
#   role       = aws_iam_role.datadog.name
#   policy_arn = aws_iam_policy.cloudtrail.arn
# }
