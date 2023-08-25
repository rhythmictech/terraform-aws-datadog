
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

variable "cspm_resource_collection_enabled" {
  default     = "false"
  description = "Whether Datadog collects cloud security posture management resources from your AWS account. This includes additional resources not covered under the general resource_collection."
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
    ml                             = false
    mq                             = false
    msk                            = false
    mwaa                           = false
    nat_gateway                    = false
    neptune                        = false
    network_elb                    = false
    networkfirewall                = false
    opsworks                       = false
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
    service_quotas                 = false
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

##########################################
# RDS Enhanced Monitoring
##########################################

variable "install_rds_enhanced_monitoring_lambda" {
  default     = true
  description = "Bool to install the RDS Enhanced Monitoring Lambda"
  type        = bool
}
