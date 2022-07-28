
variable "name" {
  description = "Moniker to apply to all resources in the module"
  type        = string
}

variable "tags" {
  default     = {}
  description = "User-Defined tags"
  type        = map(string)
}

variable "cloudtrail_buckets" {
  default     = []
  description = "Bucket(s) to collect CloudTrail logs from"
  type        = list(string)
}

variable "datadog_account_id" {
  default     = "464622532012"
  description = "DataDog AWS account ID (should not need changed)"
  type        = string
}

variable "datadog_site_name" {
  default     = "datadoghq.com"
  description = "DataDog site (e.g., datadoghq.com)"
  type        = string
}

variable "enable_guardduty_notifications" {
  default     = true
  description = "Send GuardDuty notifications to Datadog (`install_log_forwarder` must be true)"
  type        = bool
}

variable "install_log_forwarder" {
  default     = true
  description = "controls whether log forwarder lambda should be installed"
  type        = bool
}

variable "integration_filter_tags" {
  default     = []
  description = "Tags to filter EC2 instances on (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws)"
  type        = list(string)
}

variable "integration_host_tags" {
  default     = []
  description = "Tags to apply to instances (see https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws)"
  type        = list(string)
}

variable "integration_excluded_regions" {
  default     = []
  description = "Regions to exclude from DataDog monitoring"
  type        = list(string)
}

variable "integration_namespace_rules" {
  default     = {}
  description = "List of AWS services to allow in the integration. Defaults to all."
  type        = map(bool)
}

variable "log_forwarder_sources" {
  default     = []
  type        = list(string)
  description = "List of services to automatically ingest all logs from (see https://docs.datadoghq.com/api/latest/aws-logs-integration/#get-list-of-aws-log-ready-services)"
}

variable "use_cspm_permissions" {
  default     = false
  description = "Controls whether SecurityAudit policy is attached for DataDog CSPM"
  type        = bool
}

variable "use_full_permissions" {
  default     = true
  description = "Controls whether DataDog is given full permissions or core permissions. Generally you want full."
  type        = bool
}
