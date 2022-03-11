output "iam_role_datadog" {
  description = "IAM role assumed by Datadog resources"
  value       = aws_iam_role.datadog.name
}

output "lambda_arn_forwarder" {
  description = "DataDog Lambda Forwarder ARN"
  value       = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
}
