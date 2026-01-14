
variable "name" {
  description = "Moniker to apply to all resources in the module"
  type        = string
}

variable "tags" {
  default     = {}
  description = "User-Defined tags"
  type        = map(string)
}

variable "access_method" {
  default     = "role"
  description = "Access method to use for Datadog integration (recommended not to change unless using GovCloud or China regions, must be either `user` or `role`)"
  type        = string

  validation {
    condition     = var.access_method == "user" || var.access_method == "role"
    error_message = "The access_method must be either 'user' or 'role'."
  }
}

variable "cur_bucket_suffix" {
  default     = "datadog-cur-data"
  description = "Suffix to append to the CUR bucket name ([ACCOUNT_ID]-[REGION]-[cur_bucket_suffix])"
  type        = string
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

variable "enable_cur_collection" {
  default     = false
  description = "Configure a Cost and Usage Reporting export (uses legacy CUR) suitable for ingestion by Datadog. This does not fully configure Datadog due to lack of Terraform support but does do everything on the AWS side to prepare for enabling cost monitoring in Datadog."
  type        = bool
}

variable "enable_cspm_resource_collection" {
  default     = false
  description = "Whether Datadog collects cloud security posture management resources from your AWS account. This includes additional resources not covered under the general resource_collection."
  type        = bool
}

variable "enable_guardduty_notifications" {
  default     = true
  description = "Send GuardDuty notifications to Datadog (`install_log_forwarder` must be true). This routes GuardDuty events to the log forwarder. GuardDuty events can also be received as a Datadog Event through Cloud Security Monitoring."
  type        = bool
}

variable "enable_health_notifications" {
  default     = true
  description = "Send AWS health notifications to Datadog (`install_log_forwarder` must be true). This routes AWS Health events to the log forwarder. Health events can also be received as a Datadog Event through the AWS Health integration."
  type        = bool
}

variable "enable_resource_collection" {
  description = "Enable or disable resource collection"
  type        = bool
  default     = true
}

variable "enable_securityhub_notifications" {
  default     = false
  description = "Send Security Hub notifications to Datadog (`install_log_forwarder` must be true). This routes Security Hub events to the log forwarder."
  type        = bool
}

variable "forward_buckets" {
  default     = []
  description = "Bucket(s) to collect logs from (using object notifications)"
  type        = list(string)
}

variable "forward_log_groups" {
  default     = []
  description = "CloudWatch Log Group names to collect logs from (using filter subscriptions)"
  type        = list(string)
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
  description = "Map of AWS services to allow in the integration. Defaults to none."
  type        = map(bool)
}

variable "integration_default_namespace_rules" {
  default = {
    api_gateway                    = false
    application_elb                = false
    apprunner                      = false
    appstream                      = false
    appsync                        = false
    athena                         = false
    auto_scaling                   = false
    backup                         = false
    bedrock                        = false
    billing                        = false
    budgeting                      = false
    certificatemanager             = false
    cloudfront                     = false
    cloudhsm                       = false
    cloudsearch                    = false
    cloudwatch_events              = false
    cloudwatch_logs                = false
    codebuild                      = false
    codewhisperer                  = false
    cognito                        = false
    collect_custom_metrics         = false
    connect                        = false
    crawl_alarms                   = false
    directconnect                  = false
    dms                            = false
    documentdb                     = false
    dynamodb                       = false
    dynamodbaccelerator            = false
    ebs                            = false
    ec2                            = false
    ec2api                         = false
    ec2spot                        = false
    ecr                            = false
    ecs                            = false
    efs                            = false
    elasticache                    = false
    elasticbeanstalk               = false
    elasticinference               = false
    elastictranscoder              = false
    elb                            = false
    emr                            = false
    es                             = false
    firehose                       = false
    fsx                            = false
    gamelift                       = false
    globalaccelerator              = false
    glue                           = false
    inspector                      = false
    iot                            = false
    keyspaces                      = false
    kinesis                        = false
    kinesis_analytics              = false
    kms                            = false
    lambda                         = false
    lex                            = false
    mediaconnect                   = false
    mediaconvert                   = false
    medialive                      = false
    mediapackage                   = false
    mediastore                     = false
    mediatailor                    = false
    memorydb                       = false
    ml                             = false
    mq                             = false
    msk                            = false
    mwaa                           = false
    nat_gateway                    = false
    neptune                        = false
    network_elb                    = false
    networkfirewall                = false
    networkmonitor                 = false
    polly                          = false
    privatelinkendpoints           = false
    privatelinkservices            = false
    rds                            = false
    rdsproxy                       = false
    redshift                       = false
    rekognition                    = false
    route53                        = false
    route53resolver                = false
    s3                             = false
    s3storagelens                  = false
    sagemaker                      = false
    sagemakerendpoints             = false
    sagemakerlabelingjobs          = false
    sagemakermodelbuildingpipeline = false
    sagemakerprocessingjobs        = false
    sagemakertrainingjobs          = false
    sagemakertransformjobs         = false
    sagemakerworkteam              = false
    ses                            = false
    shield                         = false
    sns                            = false
    sqs                            = false
    step_functions                 = false
    storage_gateway                = false
    swf                            = false
    textract                       = false
    transitgateway                 = false
    translate                      = false
    trusted_advisor                = false
    usage                          = false
    vpn                            = false
    waf                            = false
    wafv2                          = false
    workspaces                     = false
    xray                           = false
  }

  description = "Set all services to disabled by default."
  type        = map(bool)
}

variable "log_forwarder_lambda_log_retention_days" {
  default     = 90
  description = "The number of days to retain logs for the log forwarder lambda"
  type        = number
}

variable "log_forwarder_sources" {
  default     = []
  type        = list(string)
  description = "List of services to automatically ingest all logs from (see https://docs.datadoghq.com/api/latest/aws-logs-integration/#get-list-of-aws-log-ready-services)"
}

variable "use_full_permissions" {
  default     = true
  description = "Controls whether DataDog is given full permissions or core permissions. Generally you want full."
  type        = bool
}

##########################################
# RDS Enhanced Monitoring
##########################################

variable "enable_rds_enhanced_monitoring_lambda" {
  default     = false
  description = "Install the RDS Enhanced Monitoring Lambda"
  type        = bool
}

variable "rds_enhanced_monitoring_forwarder_version" {
  default     = "3.103.0"
  description = "Version of the Datadog RDS enhanced monitoring lambda to use (module is only tested against the default version)"
  type        = string

}
########################################
# Main Index Config
########################################
variable "logs_manage_main_index" {
  default     = false
  description = "A boolean flag to manage the main Datadog logs index"
  type        = bool
}

variable "logs_main_index_daily_limit" {
  default     = null
  description = "Daily log limit for the main index (only used if `logs_manage_main_index == true`)"
  type        = number
}

variable "logs_main_index_daily_limit_reset_time" {
  default     = "00:00"
  description = "The reset time for the daily limit of the main logs index (specify as HH:MM)"
  type        = string
}

variable "logs_main_index_daily_limit_reset_offset" {
  default     = "+00:00"
  description = "The reset time timezone offset for the daily limit of the main logs index (specify as +HH:MM or -HH:MM)"
  type        = string
}

variable "logs_main_index_daily_limit_warn_threshold" {
  default     = 0.9
  description = "Warning threshold for daily log volume for the main index (only used if `logs_manage_main_index == true`)"
  type        = number
}

variable "logs_main_index_retention_days" {
  default     = 15
  description = "The number of days to retain logs in the main index (only used if `logs_manage_main_index == true`)"
  type        = number
}

variable "logs_main_index_exclusion_filters" {
  default     = []
  description = "A list of maps defining exclusion filters for the main index"
  type = list(object({
    name       = string
    is_enabled = bool
    filter = object({
      query       = string
      sample_rate = number
    })
  }))
}

########################################
# Estimated Usage Anomaly/Forecast Detection
########################################
variable "enable_estimated_usage_detection" {
  default     = false
  description = "Enable estimated usage anomaly and forecast monitoring"
  type        = bool
}

variable "estimated_usage_detection_default_config" {
  description = <<END
Map of default usage monitoring settings for each metric type. All are disabled by default.

Anomaly monitoring uses Datadog's anomaly detection feature. See https://docs.datadoghq.com/monitors/types/anomaly/ for documentation.

Estimated usage monitoring uses simple thresholds on the `estimated_usage` metric family. By default, host thresholds are by day,
as Datadog uses the peak instance count for the month on a 99th percentile basis. It may make sense to make this a shorter window,
especially if you have variable workloads. Log monitors are cumulative across the month, from the first day of the month at 00:00 UTC.
END

  default = {
    hosts = {
      # anomaly monitoring
      anomaly_enabled     = false
      anomaly_span        = "last_1d"
      anomaly_threshold   = 0.15
      anomaly_window      = "last_1h"
      anomaly_deviations  = 1
      anomaly_seasonality = "daily"
      anomaly_rollup      = 600

      # estimated usage monitoring
      estimated_usage_enabled   = false
      estimated_usage_span      = "current_1d"
      estimated_usage_threshold = 1000 # always override when using
    }
    logs_indexed = {
      # anomaly monitoring
      anomaly_enabled     = false
      anomaly_span        = "last_1d"
      anomaly_threshold   = 0.15
      anomaly_window      = "last_1h"
      anomaly_deviations  = 2
      anomaly_seasonality = "hourly"
      anomaly_rollup      = 60

      # estimated usage monitoring
      estimated_usage_enabled   = false
      estimated_usage_span      = "current_1mo" # not recommended to change this
      estimated_usage_threshold = 1000          # always override when using
    }
    logs_ingested = {
      # anomaly monitoring
      anomaly_enabled     = false
      anomaly_window      = "last_1h"
      anomaly_span        = "last_1d"
      anomaly_threshold   = 0.15
      anomaly_deviations  = 2
      anomaly_seasonality = "hourly"
      anomaly_rollup      = 60

      # estimated usage monitoring
      estimated_usage_enabled   = false
      estimated_usage_span      = "current_1mo" # not recommended to change this
      estimated_usage_threshold = 1000          # always override when using

    }
  }

  type = map(object({
    anomaly_enabled           = bool
    anomaly_span              = string
    anomaly_threshold         = number
    anomaly_window            = string
    anomaly_deviations        = number
    anomaly_seasonality       = string
    anomaly_rollup            = number
    estimated_usage_enabled   = bool
    estimated_usage_span      = optional(string)
    estimated_usage_threshold = number
  }))

}

variable "estimated_usage_detection_config" {
  default     = {}
  description = "Map of usage types to monitor."
  type        = map(any)
}

variable "estimated_usage_anomaly_message" {
  default     = "Datadog usage anomaly detected"
  description = "Message for usage anomaly alerts"
  type        = string
}

variable "estimated_usage_threshold_message" {
  default     = "Datadog usage threshold exceeded"
  description = "Message for usage threshold alerts"
  type        = string
}

variable "log_limit_exceeded_message" {
  default     = null
  description = "Message for log limit warning alerts (alert suppressed if null)"
  type        = string
}

variable "renotify_interval" {
  default     = 30
  description = "Renotify interval for all alerts (set to null to disable)"
  type        = number
}

variable "renotify_statuses" {
  default     = ["alert"]
  description = "Renotify statuses for all alerts (not used if `renotify_interval` is null)"
  type        = list(string)
  validation {
    condition     = alltrue([for s in var.renotify_statuses : contains(["alert", "no data", "warn"], s)])
    error_message = "The renotify_statuses must be a list of 'alert', 'no data', or 'warn'."
  }
}
