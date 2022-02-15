terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74"
    }

    datadog = {
      source  = "datadog/datadog"
      version = "~>3.8"
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
  source = "rhythmictech/datadog/aws"

  name                  = "datadog-integration"
  install_log_forwarder = true
  log_forwarder_sources = ["lambda"]
}
