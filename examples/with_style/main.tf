terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.62"
    }

    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.37"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.12"
    }
  }
}

provider "aws" {
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

module "datadog" {
  source = "../.."

  name                            = "datadog-integration"
  enable_cspm_resource_collection = true
  enable_cur_collection           = true
  enable_resource_collection      = true
  enable_guardduty_notifications  = false # forwarded to security account
  enable_health_notifications     = true
  install_log_forwarder           = true
  integration_filter_tags         = ["datadog_managed:true"]

  # logs
  logs_manage_main_index                     = true
  logs_main_index_daily_limit                = 700000
  logs_main_index_daily_limit_warn_threshold = 50

  # usage
  enable_estimated_usage_detection = true

  estimated_usage_detection_config = {
    hosts = {
      anomaly_enabled    = true
      forecast_enabled   = true
      forecast_threshold = 230
    }
    logs_indexed = {
      anomaly_enabled    = true
      forecast_enabled   = true
      forecast_threshold = 50000000
    }
    logs_ingested = {
      anomaly_enabled    = true
      forecast_enabled   = true
      forecast_threshold = 70000000000
    }
  }

  # metrics
  integration_namespace_rules = {
    "application_elb"    = true
    "auto_scaling"       = true
    "backup"             = true
    "billing"            = true
    "budgeting"          = true
    "certificatemanager" = true
    "cloudwatch_events"  = true
    "ebs"                = true
    "ec2"                = true
    "ecs"                = true
    "elb"                = true
    "es"                 = true
    "lambda"             = true
    "rds"                = true
    "s3"                 = true
    "service_quotas"     = true
    "ses"                = true
    "sns"                = true
    "usage"              = true
  }
}
