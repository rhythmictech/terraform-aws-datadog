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
A bit about this module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.74 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | ~>3.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | rhythmictech/tags/terraform | ~> 1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.datadog_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_iam_policy.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
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
| <a name="input_cloudtrail_buckets"></a> [cloudtrail\_buckets](#input\_cloudtrail\_buckets) | CloudTrail buckets to grant DataDog read access to | `list(string)` | `[]` | no |
| <a name="input_datadog_account_id"></a> [datadog\_account\_id](#input\_datadog\_account\_id) | DataDog AWS account ID (should not need changed) | `string` | `"464622532012"` | no |
| <a name="input_datadog_site_name"></a> [datadog\_site\_name](#input\_datadog\_site\_name) | DataDog site (e.g., datadoghq.com) | `string` | `"datadoghq.com"` | no |
| <a name="input_install_log_forwarder"></a> [install\_log\_forwarder](#input\_install\_log\_forwarder) | controls whether log forwarder lambda should be installed | `bool` | `true` | no |
| <a name="input_integration_excluded_regions"></a> [integration\_excluded\_regions](#input\_integration\_excluded\_regions) | Regions to exclude from DataDog monitoring | `list(string)` | `[]` | no |
| <a name="input_integration_filter_tags"></a> [integration\_filter\_tags](#input\_integration\_filter\_tags) | Tags to filter EC2 instances on (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws) | `list(string)` | `[]` | no |
| <a name="input_integration_host_tags"></a> [integration\_host\_tags](#input\_integration\_host\_tags) | Tags to apply to instances (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws) | `list(string)` | `[]` | no |
| <a name="input_log_forwarder_sources"></a> [log\_forwarder\_sources](#input\_log\_forwarder\_sources) | List of services to automatically ingest all logs from (see https://docs.datadoghq.com/api/latest/aws-logs-integration/#get-list-of-aws-log-ready-services) | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Moniker to apply to all resources in the module | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | User-Defined tags | `map(string)` | `{}` | no |
| <a name="input_use_cspm_permissions"></a> [use\_cspm\_permissions](#input\_use\_cspm\_permissions) | Controls whether SecurityAudit policy is attached for DataDog CSPM | `bool` | `false` | no |
| <a name="input_use_full_permissions"></a> [use\_full\_permissions](#input\_use\_full\_permissions) | Controls whether DataDog is given full permissions or core permissions. Generally you want full. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
