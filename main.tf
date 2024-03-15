data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

module "tags" {
  source  = "rhythmictech/tags/terraform"
  version = "~> 1.1"

  enforce_case = "UPPER"
  names        = [var.name]
  tags         = var.tags
}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  policy_file_path = var.use_full_permissions ? "${path.module}/iam-fullperms.json" : "${path.module}/iam-partialperms.json"
  region           = data.aws_region.current.name
  tags             = module.tags.tags_no_name
}

resource "datadog_api_key" "datadog" {
  name = var.name
}

resource "datadog_integration_aws" "datadog" {
  account_id                       = local.account_id
  account_specific_namespace_rules = merge(var.integration_default_namespace_rules, var.integration_namespace_rules)
  cspm_resource_collection_enabled = var.enable_cspm_resource_collection
  excluded_regions                 = var.integration_excluded_regions
  filter_tags                      = var.integration_filter_tags
  host_tags                        = var.integration_host_tags
  metrics_collection_enabled       = true
  resource_collection_enabled      = var.enable_resource_collection
  role_name                        = var.access_method == "role" ? "DatadogIntegrationRole" : null

  # use iam user for govcloud and china
  access_key_id     = var.access_method == "user" ? aws_iam_access_key.datadog[0].id : null
  secret_access_key = var.access_method == "user" ? aws_iam_access_key.datadog[0].secret : null
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "datadog" {
  name_prefix = "${var.name}-api-key"
  description = "Datadog API Key"
}

resource "aws_secretsmanager_secret_version" "datadog" {
  secret_id     = aws_secretsmanager_secret.datadog.id
  secret_string = datadog_api_key.datadog.key
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.datadog_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [datadog_integration_aws.datadog.external_id]
    }
  }
}

moved {
  from = aws_iam_role.datadog
  to   = aws_iam_role.datadog[0]
}

resource "aws_iam_role" "datadog" {
  count = var.access_method == "role" ? 1 : 0

  # this cannot be a prefix or it will create a cycle with the DD integration
  name               = "DatadogIntegrationRole"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = local.tags
}

resource "aws_iam_user" "datadog" {
  count = var.access_method == "user" ? 1 : 0

  name = "DatadogIntegrationUser"
  tags = local.tags
}

resource "aws_iam_access_key" "datadog" {
  count = var.access_method == "user" ? 1 : 0

  user = aws_iam_user.datadog[0].name
}

resource "aws_iam_policy" "datadog" {
  name_prefix = var.name
  path        = "/"
  policy      = file(local.policy_file_path)
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cspm" { #tfsec:ignore:AVD-AWS-0057
  count = var.enable_cspm_resource_collection && var.access_method == "role" ? 1 : 0

  role       = aws_iam_role.datadog[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_user_policy_attachment" "cspm_user" { #tfsec:ignore:AVD-AWS-0057
  count = var.enable_cspm_resource_collection && var.access_method == "user" ? 1 : 0

  user       = aws_iam_user.datadog[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

moved {
  from = aws_iam_role_policy_attachment.datadog
  to   = aws_iam_role_policy_attachment.datadog[0]
}

resource "aws_iam_role_policy_attachment" "datadog" {
  count = var.access_method == "role" ? 1 : 0

  role       = aws_iam_role.datadog[0].name
  policy_arn = aws_iam_policy.datadog.arn
}

resource "aws_iam_user_policy_attachment" "datadog" {
  count = var.access_method == "user" ? 1 : 0

  user       = aws_iam_user.datadog[0].name
  policy_arn = aws_iam_policy.datadog.arn
}

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

resource "datadog_integration_aws_log_collection" "datadog_forwarder" {
  count      = var.install_log_forwarder ? 1 : 0
  account_id = local.account_id
  services   = var.log_forwarder_sources

  depends_on = [aws_cloudformation_stack.datadog_forwarder]
}
