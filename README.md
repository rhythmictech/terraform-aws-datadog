# terraform-aws-datadog
[![tflint](https://github.com/rhythmictech/terraform-aws-datadog/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-datadog/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-datadog/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-datadog/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-datadog/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-datadog/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

Creates and manages a Datadog AWS integration. This module performs the necessary integrations in both Datadog and AWS and thus uses providers for each. Supported features include:

* AWS Health event forwarding
* CloudTrail log forwarding
* Cost and Usage report configuration
* GuardDuty finding forwarding
* Main log index configuration
* RDS enhanced monitoring
* Usage anomaly detection

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
RDS Metric Capture requires an additional Lambda. We pull that Lambda directly from the Datadog repo it is actively developed in. You can specify the version of the forwarder but the module is tested against the default version.

Example adding RDS metrics forwarding and logging:
```

import {
  to = aws_cloudwatch_log_group.rds_group
  id = "/aws/rds/instance/production-db/postgresql"
}

resource "aws_cloudwatch_log_group" "rds_group" {
  name              = "/aws/rds/instance/production-db/postgresql"
  retention_in_days = 14
}

resource "aws_lambda_permission" "cloudwatch" {

  statement_id  = "datadog-forwarder-RDSCloudWatchLogsPermission"
  action        = "lambda:InvokeFunction"
  function_name = reverse(split(":", module.datadog.lambda_arn_forwarder))[0]
  principal     = "logs.amazonaws.com"
  source_arn    = "arn:aws:logs:us-east-1:0123456789012:log-group:/aws/rds/instance/production-db/postgresql:*"
}

resource "aws_cloudwatch_log_subscription_filter" "rds_log_forwarding" {
  name            = "production-db"
  log_group_name  = "/aws/rds/instance/production-db/postgresql"
  filter_pattern  = ""
  destination_arn = module.datadog.lambda_arn_forwarder
}

module "datadog" {
  source  = "rhythmictech/datadog/aws"

  name                                          = "datadog-integration"
  enable_cspm_resource_collection               = true
  install_log_forwarder                         = true
  install_rds_enhanced_monitoring_lambda        = true
  log_forwarder_sources                         = ["lambda"]
  tags                                          = local.tags
}



```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.37 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.39.1 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.37.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | rhythmictech/tags/terraform | ~> 1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.datadog_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_cloudwatch_event_rule.awshealth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.securityhub_to_datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.awshealth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.securityhub_to_datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_subscription_filter.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_log_subscription_filter.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cur_report_definition.cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cur_report_definition) | resource |
| [aws_iam_access_key.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.datadog_cost_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cspm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datadog_cost_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.cspm_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_lambda_function.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.awshealth_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.bucket_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.guardduty_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.securityhub_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [datadog_api_key.datadog](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/api_key) | resource |
| [datadog_integration_aws.datadog](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws) | resource |
| [datadog_integration_aws_lambda_arn.datadog_forwarder](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_lambda_arn) | resource |
| [datadog_integration_aws_log_collection.datadog_forwarder](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_log_collection) | resource |
| [datadog_logs_custom_pipeline.health](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/logs_custom_pipeline) | resource |
| [datadog_logs_index.main](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/logs_index) | resource |
| [datadog_monitor.anomaly_usage](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.forecast_usage](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/monitor) | resource |
| [null_resource.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_datadog_forwarder](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [archive_file.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.datadog_cost_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.local_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_enhanced_monitoring_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_method"></a> [access\_method](#input\_access\_method) | Access method to use for Datadog integration (recommended not to change unless using GovCloud or China regions, must be either `user` or `role`) | `string` | `"role"` | no |
| <a name="input_cur_bucket_suffix"></a> [cur\_bucket\_suffix](#input\_cur\_bucket\_suffix) | Suffix to append to the CUR bucket name ([ACCOUNT\_ID]-[REGION]-[cur\_bucket\_suffix]) | `string` | `"datadog-cur-data"` | no |
| <a name="input_datadog_account_id"></a> [datadog\_account\_id](#input\_datadog\_account\_id) | DataDog AWS account ID (should not need changed) | `string` | `"464622532012"` | no |
| <a name="input_datadog_site_name"></a> [datadog\_site\_name](#input\_datadog\_site\_name) | DataDog site (e.g., datadoghq.com) | `string` | `"datadoghq.com"` | no |
| <a name="input_enable_cspm_resource_collection"></a> [enable\_cspm\_resource\_collection](#input\_enable\_cspm\_resource\_collection) | Whether Datadog collects cloud security posture management resources from your AWS account. This includes additional resources not covered under the general resource\_collection. | `bool` | `false` | no |
| <a name="input_enable_cur_collection"></a> [enable\_cur\_collection](#input\_enable\_cur\_collection) | Configure a Cost and Usage Reporting export (uses legacy CUR) suitable for ingestion by Datadog. This does not fully configure Datadog due to lack of Terraform support but does do everything on the AWS side to prepare for enabling cost monitoring in Datadog. | `bool` | `false` | no |
| <a name="input_enable_estimated_usage_detection"></a> [enable\_estimated\_usage\_detection](#input\_enable\_estimated\_usage\_detection) | Enable estimated usage anomaly and forecast monitoring | `bool` | `false` | no |
| <a name="input_enable_guardduty_notifications"></a> [enable\_guardduty\_notifications](#input\_enable\_guardduty\_notifications) | Send GuardDuty notifications to Datadog (`install_log_forwarder` must be true). This routes GuardDuty events to the log forwarder. GuardDuty events can also be received as a Datadog Event through Cloud Security Monitoring. | `bool` | `true` | no |
| <a name="input_enable_health_notifications"></a> [enable\_health\_notifications](#input\_enable\_health\_notifications) | Send AWS health notifications to Datadog (`install_log_forwarder` must be true). This routes AWS Health events to the log forwarder. Health events can also be received as a Datadog Event through the AWS Health integration. | `bool` | `true` | no |
| <a name="input_enable_rds_enhanced_monitoring_lambda"></a> [enable\_rds\_enhanced\_monitoring\_lambda](#input\_enable\_rds\_enhanced\_monitoring\_lambda) | Install the RDS Enhanced Monitoring Lambda | `bool` | `false` | no |
| <a name="input_enable_resource_collection"></a> [enable\_resource\_collection](#input\_enable\_resource\_collection) | Enable or disable resource collection | `bool` | `true` | no |
| <a name="input_enable_securityhub_notifications"></a> [enable\_securityhub\_notifications](#input\_enable\_securityhub\_notifications) | Send Security Hub notifications to Datadog (`install_log_forwarder` must be true). This routes Security Hub events to the log forwarder. | `bool` | `false` | no |
| <a name="input_estimated_usage_anomaly_message"></a> [estimated\_usage\_anomaly\_message](#input\_estimated\_usage\_anomaly\_message) | Message for usage anomaly alerts | `string` | `"Datadog usage anomaly detected"` | no |
| <a name="input_estimated_usage_detection_config"></a> [estimated\_usage\_detection\_config](#input\_estimated\_usage\_detection\_config) | Map of usage types to monitor. | `map(any)` | `{}` | no |
| <a name="input_estimated_usage_detection_default_config"></a> [estimated\_usage\_detection\_default\_config](#input\_estimated\_usage\_detection\_default\_config) | Map of default usage monitoring settings for each metric type. All are disabled by default. Use `usage_anomaly_services` to enable services and alternately override default settings | <pre>map(object({<br>    anomaly_enabled       = bool<br>    anomaly_span          = string<br>    anomaly_threshold     = number<br>    anomaly_window        = string<br>    anomaly_deviations    = number<br>    anomaly_seasonality   = string<br>    anomaly_rollup        = number<br>    forecast_enabled      = bool<br>    forecast_deviations   = number<br>    forecast_rollup_type  = string<br>    forecast_rollup_value = number<br>    forecast_threshold    = number<br>  }))</pre> | <pre>{<br>  "hosts": {<br>    "anomaly_deviations": 1,<br>    "anomaly_enabled": false,<br>    "anomaly_rollup": 600,<br>    "anomaly_seasonality": "daily",<br>    "anomaly_span": "last_1d",<br>    "anomaly_threshold": 0.15,<br>    "anomaly_window": "last_1h",<br>    "forecast_deviations": 1,<br>    "forecast_enabled": false,<br>    "forecast_rollup_type": "avg",<br>    "forecast_rollup_value": 300,<br>    "forecast_threshold": 1000<br>  },<br>  "logs_indexed": {<br>    "anomaly_deviations": 2,<br>    "anomaly_enabled": false,<br>    "anomaly_rollup": 60,<br>    "anomaly_seasonality": "hourly",<br>    "anomaly_span": "last_1d",<br>    "anomaly_threshold": 0.15,<br>    "anomaly_window": "last_1h",<br>    "forecast_deviations": 1,<br>    "forecast_enabled": false,<br>    "forecast_rollup_type": "sum",<br>    "forecast_rollup_value": 86400,<br>    "forecast_threshold": 1000<br>  },<br>  "logs_ingested": {<br>    "anomaly_deviations": 2,<br>    "anomaly_enabled": false,<br>    "anomaly_rollup": 60,<br>    "anomaly_seasonality": "hourly",<br>    "anomaly_span": "last_1d",<br>    "anomaly_threshold": 0.15,<br>    "anomaly_window": "last_1h",<br>    "forecast_deviations": 1,<br>    "forecast_enabled": false,<br>    "forecast_rollup_type": "sum",<br>    "forecast_rollup_value": 86400,<br>    "forecast_threshold": 1000<br>  }<br>}</pre> | no |
| <a name="input_forward_buckets"></a> [forward\_buckets](#input\_forward\_buckets) | Bucket(s) to collect logs from (using object notifications) | `list(string)` | `[]` | no |
| <a name="input_forward_log_groups"></a> [forward\_log\_groups](#input\_forward\_log\_groups) | CloudWatch Log Group names to collect logs from (using filter subscriptions) | `list(string)` | `[]` | no |
| <a name="input_install_log_forwarder"></a> [install\_log\_forwarder](#input\_install\_log\_forwarder) | controls whether log forwarder lambda should be installed | `bool` | `true` | no |
| <a name="input_integration_default_namespace_rules"></a> [integration\_default\_namespace\_rules](#input\_integration\_default\_namespace\_rules) | Set all services to disabled by default. | `map(bool)` | <pre>{<br>  "api_gateway": false,<br>  "application_elb": false,<br>  "apprunner": false,<br>  "appstream": false,<br>  "appsync": false,<br>  "athena": false,<br>  "auto_scaling": false,<br>  "backup": false,<br>  "bedrock": false,<br>  "billing": false,<br>  "budgeting": false,<br>  "certificatemanager": false,<br>  "cloudfront": false,<br>  "cloudhsm": false,<br>  "cloudsearch": false,<br>  "cloudwatch_events": false,<br>  "cloudwatch_logs": false,<br>  "codebuild": false,<br>  "codewhisperer": false,<br>  "cognito": false,<br>  "collect_custom_metrics": false,<br>  "connect": false,<br>  "crawl_alarms": false,<br>  "directconnect": false,<br>  "dms": false,<br>  "documentdb": false,<br>  "dynamodb": false,<br>  "dynamodbaccelerator": false,<br>  "ebs": false,<br>  "ec2": false,<br>  "ec2api": false,<br>  "ec2spot": false,<br>  "ecr": false,<br>  "ecs": false,<br>  "efs": false,<br>  "elasticache": false,<br>  "elasticbeanstalk": false,<br>  "elasticinference": false,<br>  "elastictranscoder": false,<br>  "elb": false,<br>  "emr": false,<br>  "es": false,<br>  "firehose": false,<br>  "fsx": false,<br>  "gamelift": false,<br>  "globalaccelerator": false,<br>  "glue": false,<br>  "inspector": false,<br>  "iot": false,<br>  "keyspaces": false,<br>  "kinesis": false,<br>  "kinesis_analytics": false,<br>  "kms": false,<br>  "lambda": false,<br>  "lex": false,<br>  "mediaconnect": false,<br>  "mediaconvert": false,<br>  "medialive": false,<br>  "mediapackage": false,<br>  "mediastore": false,<br>  "mediatailor": false,<br>  "memorydb": false,<br>  "ml": false,<br>  "mq": false,<br>  "msk": false,<br>  "mwaa": false,<br>  "nat_gateway": false,<br>  "neptune": false,<br>  "network_elb": false,<br>  "networkfirewall": false,<br>  "networkmonitor": false,<br>  "opsworks": false,<br>  "polly": false,<br>  "privatelinkendpoints": false,<br>  "privatelinkservices": false,<br>  "rds": false,<br>  "rdsproxy": false,<br>  "redshift": false,<br>  "rekognition": false,<br>  "route53": false,<br>  "route53resolver": false,<br>  "s3": false,<br>  "s3storagelens": false,<br>  "sagemaker": false,<br>  "sagemakerendpoints": false,<br>  "sagemakerlabelingjobs": false,<br>  "sagemakermodelbuildingpipeline": false,<br>  "sagemakerprocessingjobs": false,<br>  "sagemakertrainingjobs": false,<br>  "sagemakertransformjobs": false,<br>  "sagemakerworkteam": false,<br>  "service_quotas": false,<br>  "ses": false,<br>  "shield": false,<br>  "sns": false,<br>  "sqs": false,<br>  "step_functions": false,<br>  "storage_gateway": false,<br>  "swf": false,<br>  "textract": false,<br>  "transitgateway": false,<br>  "translate": false,<br>  "trusted_advisor": false,<br>  "usage": false,<br>  "vpn": false,<br>  "waf": false,<br>  "wafv2": false,<br>  "workspaces": false,<br>  "xray": false<br>}</pre> | no |
| <a name="input_integration_excluded_regions"></a> [integration\_excluded\_regions](#input\_integration\_excluded\_regions) | Regions to exclude from DataDog monitoring | `list(string)` | `[]` | no |
| <a name="input_integration_filter_tags"></a> [integration\_filter\_tags](#input\_integration\_filter\_tags) | Tags to filter EC2 instances on (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws) | `list(string)` | `[]` | no |
| <a name="input_integration_host_tags"></a> [integration\_host\_tags](#input\_integration\_host\_tags) | Tags to apply to instances (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws) | `list(string)` | `[]` | no |
| <a name="input_integration_namespace_rules"></a> [integration\_namespace\_rules](#input\_integration\_namespace\_rules) | Map of AWS services to allow in the integration. Defaults to none. | `map(bool)` | `{}` | no |
| <a name="input_log_forwarder_sources"></a> [log\_forwarder\_sources](#input\_log\_forwarder\_sources) | List of services to automatically ingest all logs from (see https://docs.datadoghq.com/api/latest/aws-logs-integration/#get-list-of-aws-log-ready-services) | `list(string)` | `[]` | no |
| <a name="input_logs_main_index_daily_limit"></a> [logs\_main\_index\_daily\_limit](#input\_logs\_main\_index\_daily\_limit) | Daily log limit for the main index (only used if `logs_manage_main_index == true`) | `number` | `null` | no |
| <a name="input_logs_main_index_daily_limit_reset_offset"></a> [logs\_main\_index\_daily\_limit\_reset\_offset](#input\_logs\_main\_index\_daily\_limit\_reset\_offset) | The reset time timezone offset for the daily limit of the main logs index (specify as +HH:MM or -HH:MM) | `string` | `"+00:00"` | no |
| <a name="input_logs_main_index_daily_limit_reset_time"></a> [logs\_main\_index\_daily\_limit\_reset\_time](#input\_logs\_main\_index\_daily\_limit\_reset\_time) | The reset time for the daily limit of the main logs index (specify as HH:MM) | `string` | `"00:00"` | no |
| <a name="input_logs_main_index_daily_limit_warn_threshold"></a> [logs\_main\_index\_daily\_limit\_warn\_threshold](#input\_logs\_main\_index\_daily\_limit\_warn\_threshold) | Warning threshold for daily log volume for the main index (only used if `logs_manage_main_index == true`) | `number` | `0.9` | no |
| <a name="input_logs_main_index_exclusion_filters"></a> [logs\_main\_index\_exclusion\_filters](#input\_logs\_main\_index\_exclusion\_filters) | A list of maps defining exclusion filters for the main index | <pre>list(object({<br>    name       = string<br>    is_enabled = bool<br>    filter = object({<br>      query       = string<br>      sample_rate = number<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_logs_main_index_retention_days"></a> [logs\_main\_index\_retention\_days](#input\_logs\_main\_index\_retention\_days) | The number of days to retain logs in the main index (only used if `logs_manage_main_index == true`) | `number` | `15` | no |
| <a name="input_logs_manage_main_index"></a> [logs\_manage\_main\_index](#input\_logs\_manage\_main\_index) | A boolean flag to manage the main Datadog logs index | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Moniker to apply to all resources in the module | `string` | n/a | yes |
| <a name="input_rds_enhanced_monitoring_forwarder_version"></a> [rds\_enhanced\_monitoring\_forwarder\_version](#input\_rds\_enhanced\_monitoring\_forwarder\_version) | Version of the Datadog RDS enhanced monitoring lambda to use (module is only tested against the default version) | `string` | `"3.103.0"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | User-Defined tags | `map(string)` | `{}` | no |
| <a name="input_use_full_permissions"></a> [use\_full\_permissions](#input\_use\_full\_permissions) | Controls whether DataDog is given full permissions or core permissions. Generally you want full. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_datadog"></a> [iam\_role\_datadog](#output\_iam\_role\_datadog) | IAM role assumed by Datadog resources |
| <a name="output_iam_user_datadog"></a> [iam\_user\_datadog](#output\_iam\_user\_datadog) | IAM user accessed by Datadog resources (when `access_method == user`) |
| <a name="output_lambda_arn_forwarder"></a> [lambda\_arn\_forwarder](#output\_lambda\_arn\_forwarder) | DataDog Lambda Forwarder ARN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
