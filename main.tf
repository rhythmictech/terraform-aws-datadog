data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_partition" "current" {
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
  partition        = data.aws_partition.current.partition
  policy_file_path = var.use_full_permissions ? "${path.module}/iam-fullperms.json" : "${path.module}/iam-partialperms.json"
  region           = data.aws_region.current.name
  tags             = module.tags.tags_no_name
}

resource "datadog_api_key" "datadog" {
  name = var.name
}

resource "datadog_integration_aws_account" "datadog" {
  aws_account_id = local.account_id
  aws_partition  = local.partition == "aws-us-gov" ? "aws-us-gov" : (local.partition == "aws-cn" ? "aws-cn" : "aws")

  aws_regions {
    include_all = length(var.integration_excluded_regions) == 0
    exclude_only = length(var.integration_excluded_regions) > 0 ? var.integration_excluded_regions : null
  }

  auth_config {
    dynamic "aws_auth_config_role" {
      for_each = var.access_method == "role" ? [1] : []
      content {
        role_name = "DatadogIntegrationRole"
      }
    }

    dynamic "aws_auth_config_keys" {
      for_each = var.access_method == "user" ? [1] : []
      content {
        access_key_id     = aws_iam_access_key.datadog[0].id
        secret_access_key = aws_iam_access_key.datadog[0].secret
      }
    }
  }

  metrics_config {
    enabled                = true
    collect_custom_metrics = lookup(merge(var.integration_default_namespace_rules, var.integration_namespace_rules), "collect_custom_metrics", false)

    automute_enabled    = true
    collect_cloudwatch_alarms = lookup(merge(var.integration_default_namespace_rules, var.integration_namespace_rules), "crawl_alarms", false)

    dynamic "tag_filters" {
      for_each = length(var.integration_filter_tags) > 0 ? [1] : []
      content {
        namespace = "AWS/EC2"
        tags      = var.integration_filter_tags
      }
    }
  }

  resources_config {
    cloud_security_posture_management_collection = var.enable_cspm_resource_collection
    extended_collection                          = var.enable_resource_collection
  }

  logs_config {
    lambda_forwarder {
      sources = var.log_forwarder_sources
    }
  }

  traces_config {
    xray_services {
      include_all = lookup(merge(var.integration_default_namespace_rules, var.integration_namespace_rules), "xray", false)
    }
  }

  account_tags = var.integration_host_tags
}

#trivy:ignore:avd-aws-0098
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
      values   = [datadog_integration_aws_account.datadog.auth_config[0].aws_auth_config_role[0].external_id]
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

#trivy:ignore:avd-aws-0057
resource "aws_iam_policy" "datadog" {
  name_prefix = var.name
  path        = "/"
  policy      = file(local.policy_file_path)
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cspm" { #trivy:ignore:avd-aws-0057
  count = (var.enable_cspm_resource_collection || var.enable_resource_collection) && var.access_method == "role" ? 1 : 0

  role       = aws_iam_role.datadog[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_user_policy_attachment" "cspm_user" { #trivy:ignore:avd-aws-0057
  count = (var.enable_cspm_resource_collection || var.enable_resource_collection) && var.access_method == "user" ? 1 : 0

  user       = aws_iam_user.datadog[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/SecurityAudit"
}

moved {
  from = aws_iam_role_policy_attachment.datadog
  to   = aws_iam_role_policy_attachment.datadog[0]
}

#trivy:ignore:avd-aws-0057
resource "aws_iam_role_policy_attachment" "datadog" {
  count = var.access_method == "role" ? 1 : 0

  role       = aws_iam_role.datadog[0].name
  policy_arn = aws_iam_policy.datadog.arn
}

#trivy:ignore:avd-aws-0057
resource "aws_iam_user_policy_attachment" "datadog" {
  count = var.access_method == "user" ? 1 : 0

  user       = aws_iam_user.datadog[0].name
  policy_arn = aws_iam_policy.datadog.arn
}
