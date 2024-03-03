terraform {
  required_version = "~> 1.5"

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
  }
}
