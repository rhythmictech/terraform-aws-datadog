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

  name                  = "datadog-integration"
  install_log_forwarder = true
  log_forwarder_sources = ["lambda"]
}
