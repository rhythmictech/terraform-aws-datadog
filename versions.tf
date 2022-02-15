terraform {
  required_version = ">= 0.14"

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
