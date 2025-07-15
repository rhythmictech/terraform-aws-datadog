locals {
  local_bucket_arn = var.enable_cur_collection ? aws_s3_bucket.local_cur[0].arn : "arn:aws:s3:::example-bucket"
}

#trivy:ignore:avd-aws-0089
resource "aws_s3_bucket" "local_cur" {
  count = var.enable_cur_collection ? 1 : 0

  bucket = "${local.account_id}-${local.region}-${var.cur_bucket_suffix}"
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "local_cur" {
  count = var.enable_cur_collection ? 1 : 0

  bucket = aws_s3_bucket.local_cur[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

#trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "local_cur" {
  count = var.enable_cur_collection ? 1 : 0

  bucket = aws_s3_bucket.local_cur[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "local_cur" {
  count = var.enable_cur_collection ? 1 : 0

  bucket = aws_s3_bucket.local_cur[0].id

  rule {
    id     = "Object&Version Expiration"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 32
    }
  }
}

resource "aws_s3_bucket_public_access_block" "local_cur" {
  count = var.enable_cur_collection ? 1 : 0

  bucket = aws_s3_bucket.local_cur[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "local_cur" {
  count = var.enable_cur_collection ? 1 : 0

  bucket = aws_s3_bucket.local_cur[0].id
  policy = data.aws_iam_policy_document.local_cur.json
}

data "aws_iam_policy_document" "local_cur" {
  statement {
    sid    = "AllowTLS12Only"
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = ["s3:*"]

    resources = [
      local.local_bucket_arn,
      "${local.local_bucket_arn}/*",
    ]

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

  statement {
    sid     = "RequireHTTPS"
    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      local.local_bucket_arn,
      "${local.local_bucket_arn}/*",
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "AllowLocalRead"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
    resources = [local.local_bucket_arn]

    principals {
      identifiers = ["billingreports.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    sid       = "AllowLocalWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${local.local_bucket_arn}/*"]

    principals {
      identifiers = ["billingreports.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "datadog_cost_policy" {
  statement {
    sid       = "DatadogCostReadBucket"
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = [local.local_bucket_arn]
  }

  statement {
    sid       = "DatadogCostGetBill"
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["${local.local_bucket_arn}/*"]
  }

  statement {
    sid = "DatadogCostCheckAccuracy"
    #trivy:ignore:avd-aws-0057
    actions = ["ce:Get*"]
    effect  = "Allow"
    #trivy:ignore:avd-aws-0057
    resources = ["*"]
  }

  statement {
    sid     = "DatadogCostListCURs"
    actions = ["cur:DescribeReportDefinitions"]
    effect  = "Allow"
    #trivy:ignore:avd-aws-0057
    resources = ["*"]
  }

  statement {
    sid    = "DatadogCostListOrganizations"
    effect = "Allow"
    #trivy:ignore:avd-aws-0057
    resources = ["*"]
    #trivy:ignore:avd-aws-0057
    actions = [
      "organizations:Describe*",
      "organizations:List*"
    ]
  }
}

resource "aws_iam_policy" "datadog_cost_policy" {
  count = var.enable_cur_collection ? 1 : 0

  name        = "DatadogCostPolicy"
  description = "IAM policy for Datadog cloud cost management"
  policy      = data.aws_iam_policy_document.datadog_cost_policy.json
}

resource "aws_iam_role_policy_attachment" "datadog_cost_policy" {
  count = var.enable_cur_collection ? 1 : 0

  role       = "DatadogIntegrationRole"
  policy_arn = aws_iam_policy.datadog_cost_policy[0].arn
}


resource "aws_cur_report_definition" "cur" {
  count = var.enable_cur_collection ? 1 : 0

  report_name = "cur"

  additional_schema_elements = ["RESOURCES"]
  compression                = "GZIP"
  format                     = "textORcsv"
  refresh_closed_reports     = true
  report_versioning          = "CREATE_NEW_REPORT"
  s3_bucket                  = aws_s3_bucket.local_cur[0].id
  s3_region                  = "us-east-1"
  time_unit                  = "HOURLY"

  depends_on = [aws_s3_bucket.local_cur[0], aws_s3_bucket_policy.local_cur[0]]
}
