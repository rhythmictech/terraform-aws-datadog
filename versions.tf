terraform {
  required_version = "~> 1.5"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.41"
    }

    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.39"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.4"
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
