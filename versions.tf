terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.62"
    }

    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.36"
    }
  }
}
