# terraform-aws-datadog
[![tflint](https://github.com/rhythmictech/terraform-aws-datadog/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-datadog/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-datadog/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-datadog/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-datadog/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

Creates and manages a Datadog AWS integration. This module performs the necessary integrations in both Datadog and AWS and thus uses providers for each.

## Requirements
* DataDog provider
* DataDog API key

## Example
This configures a DataDog integration with the log forwarder installed and configured for Lambda only.

```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

module "datadog" {
  source = "rhythmictech/datadog/aws"

  name                  = "datadog-integration"
  install_log_forwarder = true
  log_forwarder_sources = ["lambda"]
}
```

## About
By default it installs the DataDog log forwarder. Can also optionally install the RDS Enhanced metrics forwarder. 

## RDS Metrics
RDS Metric Capture requires an additional Lambda.

*Note: terraform will not apply successfully if the account is not already configured for RDS enhanced monitoring, as the metric group the Lambda depneds on will not yet exist.*
Example adding RDS metrics forwarding and logging:
```
module "datadog" {
  source  = "rhythmictech/datadog/aws"

  name                                          = "datadog-integration"
  enable_cspm_resource_collection               = true
  install_log_forwarder                         = true
  install_rds_enhanced_monitoring_lambda        = true
  log_forwarder_sources                         = ["lambda"]
  tags                                          = local.tags
}

resource "aws_lambda_permission" "cloudwatch" {

  statement_id  = "datadog-forwarder-RDSCloudWatchLogsPermission"
  action        = "lambda:InvokeFunction"
  function_name = reverse(split(":", module.datadog.lambda_arn_forwarder))[0]
  principal     = "logs.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/instance/production-db/postgresql:*"
}
resource "aws_cloudwatch_log_subscription_filter" "rds_log_forwarding" {
  name            = "production-db"
  log_group_name  = "/aws/rds/instance/production-db/postgresql"
  filter_pattern  = ""
  destination_arn = module.datadog.lambda_arn_forwarder
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.36 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.37.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.36.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds_enhanced_monitoring_lambda_code"></a> [rds\_enhanced\_monitoring\_lambda\_code](#module\_rds\_enhanced\_monitoring\_lambda\_code) | git::https://github.com/DataDog/datadog-serverless-functions.git | aws-dd-forwarder-3.100.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | rhythmictech/tags/terraform | ~> 1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.datadog_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_cloudformation_stack.rds_enhanced_monitoring_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_cloudwatch_event_rule.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cspm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.cloudtrail_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.guardduty_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.cloudtrail_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_secretsmanager_secret.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [datadog_api_key.datadog](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/api_key) | resource |
| [datadog_integration_aws.datadog](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws) | resource |
| [datadog_integration_aws_lambda_arn.datadog_forwarder](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_lambda_arn) | resource |
| [datadog_integration_aws_log_collection.datadog_forwarder](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_log_collection) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_buckets"></a> [cloudtrail\_buckets](#input\_cloudtrail\_buckets) | Bucket(s) to collect CloudTrail logs from | `list(string)` | `[]` | no |
| <a name="input_datadog_account_id"></a> [datadog\_account\_id](#input\_datadog\_account\_id) | DataDog AWS account ID (should not need changed) | `string` | `"464622532012"` | no |
| <a name="input_datadog_site_name"></a> [datadog\_site\_name](#input\_datadog\_site\_name) | DataDog site (e.g., datadoghq.com) | `string` | `"datadoghq.com"` | no |
| <a name="input_enable_cspm_resource_collection"></a> [enable\_cspm\_resource\_collection](#input\_enable\_cspm\_resource\_collection) | Whether Datadog collects cloud security posture management resources from your AWS account. This includes additional resources not covered under the general resource\_collection. | `bool` | `false` | no |
| <a name="input_enable_guardduty_notifications"></a> [enable\_guardduty\_notifications](#input\_enable\_guardduty\_notifications) | Send GuardDuty notifications to Datadog (`install_log_forwarder` must be true) | `bool` | `true` | no |
| <a name="input_enable_resource_collection"></a> [enable\_resource\_collection](#input\_enable\_resource\_collection) | Enable or disable resource collection | `bool` | `true` | no |
| <a name="input_install_log_forwarder"></a> [install\_log\_forwarder](#input\_install\_log\_forwarder) | controls whether log forwarder lambda should be installed | `bool` | `true` | no |
| <a name="input_install_rds_enhanced_monitoring_lambda"></a> [install\_rds\_enhanced\_monitoring\_lambda](#input\_install\_rds\_enhanced\_monitoring\_lambda) | Install the RDS Enhanced Monitoring Lambda | `bool` | `false` | no |
| <a name="input_integration_default_namespace_rules"></a> [integration\_default\_namespace\_rules](#input\_integration\_default\_namespace\_rules) | Set all services to disabled by default. | `map(bool)` | <pre>{<br>  "api_gateway": false,<br>  "application_elb": false,<br>  "apprunner": false,<br>  "appstream": false,<br>  "appsync": false,<br>  "athena": false,<br>  "auto_scaling": false,<br>  "backup": false,<br>  "bedrock": false,<br>  "billing": false,<br>  "budgeting": false,<br>  "certificatemanager": false,<br>  "cloudfront": false,<br>  "cloudhsm": false,<br>  "cloudsearch": false,<br>  "cloudwatch_events": false,<br>  "cloudwatch_logs": false,<br>  "codebuild": false,<br>  "codewhisperer": false,<br>  "cognito": false,<br>  "collect_custom_metrics": false,<br>  "connect": false,<br>  "crawl_alarms": false,<br>  "directconnect": false,<br>  "dms": false,<br>  "documentdb": false,<br>  "dynamodb": false,<br>  "dynamodbaccelerator": false,<br>  "ebs": false,<br>  "ec2": false,<br>  "ec2api": false,<br>  "ec2spot": false,<br>  "ecr": false,<br>  "ecs": false,<br>  "efs": false,<br>  "elasticache": false,<br>  "elasticbeanstalk": false,<br>  "elasticinference": false,<br>  "elastictranscoder": false,<br>  "elb": false,<br>  "emr": false,<br>  "es": false,<br>  "firehose": false,<br>  "fsx": false,<br>  "gamelift": false,<br>  "globalaccelerator": false,<br>  "glue": false,<br>  "inspector": false,<br>  "iot": false,<br>  "keyspaces": false,<br>  "kinesis": false,<br>  "kinesis_analytics": false,<br>  "kms": false,<br>  "lambda": false,<br>  "lex": false,<br>  "mediaconnect": false,<br>  "mediaconvert": false,<br>  "medialive": false,<br>  "mediapackage": false,<br>  "mediastore": false,<br>  "mediatailor": false,<br>  "memorydb": false,<br>  "ml": false,<br>  "mq": false,<br>  "msk": false,<br>  "mwaa": false,<br>  "nat_gateway": false,<br>  "neptune": false,<br>  "network_elb": false,<br>  "networkfirewall": false,<br>  "networkmonitor": false,<br>  "opsworks": false,<br>  "polly": false,<br>  "privatelinkendpoints": false,<br>  "privatelinkservices": false,<br>  "rds": false,<br>  "rdsproxy": false,<br>  "redshift": false,<br>  "rekognition": false,<br>  "route53": false,<br>  "route53resolver": false,<br>  "s3": false,<br>  "s3storagelens": false,<br>  "sagemaker": false,<br>  "sagemakerendpoints": false,<br>  "sagemakerlabelingjobs": false,<br>  "sagemakermodelbuildingpipeline": false,<br>  "sagemakerprocessingjobs": false,<br>  "sagemakertrainingjobs": false,<br>  "sagemakertransformjobs": false,<br>  "sagemakerworkteam": false,<br>  "service_quotas": false,<br>  "ses": false,<br>  "shield": false,<br>  "sns": false,<br>  "sqs": false,<br>  "step_functions": false,<br>  "storage_gateway": false,<br>  "swf": false,<br>  "textract": false,<br>  "transitgateway": false,<br>  "translate": false,<br>  "trusted_advisor": false,<br>  "usage": false,<br>  "vpn": false,<br>  "waf": false,<br>  "wafv2": false,<br>  "workspaces": false,<br>  "xray": false<br>}</pre> | no |
| <a name="input_integration_excluded_regions"></a> [integration\_excluded\_regions](#input\_integration\_excluded\_regions) | Regions to exclude from DataDog monitoring | `list(string)` | `[]` | no |
| <a name="input_integration_filter_tags"></a> [integration\_filter\_tags](#input\_integration\_filter\_tags) | Tags to filter EC2 instances on (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws) | `list(string)` | `[]` | no |
| <a name="input_integration_host_tags"></a> [integration\_host\_tags](#input\_integration\_host\_tags) | Tags to apply to instances (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws) | `list(string)` | `[]` | no |
| <a name="input_integration_namespace_rules"></a> [integration\_namespace\_rules](#input\_integration\_namespace\_rules) | Map of AWS services to allow in the integration. Defaults to none. | `map(bool)` | `{}` | no |
| <a name="input_log_forwarder_sources"></a> [log\_forwarder\_sources](#input\_log\_forwarder\_sources) | List of services to automatically ingest all logs from (see https://docs.datadoghq.com/api/latest/aws-logs-integration/#get-list-of-aws-log-ready-services) | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Moniker to apply to all resources in the module | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | User-Defined tags | `map(string)` | `{}` | no |
| <a name="input_use_full_permissions"></a> [use\_full\_permissions](#input\_use\_full\_permissions) | Controls whether DataDog is given full permissions or core permissions. Generally you want full. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_datadog"></a> [iam\_role\_datadog](#output\_iam\_role\_datadog) | IAM role assumed by Datadog resources |
| <a name="output_lambda_arn_forwarder"></a> [lambda\_arn\_forwarder](#output\_lambda\_arn\_forwarder) | DataDog Lambda Forwarder ARN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
