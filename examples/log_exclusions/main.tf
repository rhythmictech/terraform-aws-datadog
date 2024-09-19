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

  name                    = "datadog-integration"
  install_log_forwarder   = true
  integration_filter_tags = ["datadog_managed:true"]

  # logs
  logs_manage_main_index = true
  logs_main_index_exclusion_filters = [
    {
      name       = "Exclude Datadog agent logs"
      is_enabled = true
      filter = {
        query       = "source:runtime-security-agent"
        sample_rate = 0
      }
    },
    {
      name       = "Exclude Datadog CloudTrail logs"
      is_enabled = true
      filter = {
        query       = "service:cloudtrail @userIdentity.assumed_role:DatadogIntegrationRole status:info"
        sample_rate = 0
      }
    }
  ]
}
