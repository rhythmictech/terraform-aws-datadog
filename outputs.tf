output "iam_role_datadog" {
  description = "IAM role assumed by Datadog resources"
  value       = try(aws_iam_role.datadog[0].name, "")
}

output "iam_user_datadog" {
  description = "IAM user accessed by Datadog resources (when `access_method == user`)"
  value       = try(aws_iam_user.datadog[0].name, "")
}

output "lambda_arn_forwarder" {
  description = "DataDog Lambda Forwarder ARN"
  value       = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
}
