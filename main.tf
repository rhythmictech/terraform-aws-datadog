data "aws_caller_identity" "current" {
}

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
  tags             = module.tags.tags_no_name
}

resource "datadog_integration_aws" "datadog" {
  account_id       = local.account_id
  excluded_regions = var.integration_excluded_regions
  filter_tags      = var.integration_filter_tags
  host_tags        = var.integration_host_tags
  role_name        = "DatadogIntegrationRole"
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

resource "aws_iam_role" "datadog" {
  # this cannot be a prefix or it will create a cycle with the DD integration
  name               = "DatadogIntegrationRole"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = local.tags
}

resource "aws_iam_policy" "datadog" {
  name_prefix = var.name
  path        = "/"
  policy      = file(local.policy_file_path)
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cspm" {
  count = var.use_cspm_permissions ? 1 : 0

  role       = aws_iam_role.datadog.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "datadog" {
  role       = aws_iam_role.datadog.name
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
}

resource "datadog_integration_aws_lambda_arn" "datadog_forwarder" {
  count      = var.install_log_forwarder ? 1 : 0
  account_id = local.account_id
  lambda_arn = try(aws_cloudformation_stack.datadog_forwarder[0].outputs.DatadogForwarderArn, "")
}

resource "datadog_integration_aws_log_collection" "datadog_forwarder" {
  count      = var.install_log_forwarder ? 1 : 0
  account_id = local.account_id
  services   = var.log_forwarder_sources
}
