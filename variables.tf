
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
  default     = { }
  description = "List of AWS services to allow in the integration. Defaults to none."
  type        = map(bool)
}

variable "integration_default_namespace_rules" {
  default     = {
    api_gateway = false
    application_elb = false
    apprunner = false
    appstream = false
    appsync = false
    athena = false
    auto_scaling = false
    backup = false
    billing = false
    bracket = false
    budgeting = false
    certificatemanager = false
    cloud9 = false
    cloudfront = false
    cloudhsm = false
    cloudsearch = false
    cloudwatch_events = false
    cloudwatch_logs = false
    codeartifact = false
    codebuild = false
    codecommit = false
    codegurureviewer = false
    codepipeline = false
    cognito = false
    collect_custom_metrics = false
    comprehend = false
    config = false
    connect = false
    crawl_alarms = false
    dataexchange = false
    datapipeline = false
    directconnect = false
    dms = false
    documentdb = false
    dynamodb = false
    ebs = false
    ec2 = false
    ec2api = false
    ec2spot = false
    ecr = false
    ecs = false
    efs = false
    eks = false
    elasticache = false
    elasticbeanstalk = false
    elasticinference = false
    elasticmapreducecontainers = false
    elastictranscoder = false
    elb = false
    emr = false
    es = false
    firehose = false
    forecast = false
    frauddetector = false
    fsx = false
    gamelift = false
    glacier = false
    glue = false
    gluedatabrew = false
    iam = false
    inspector = false
    iot = false
    iotanalytics = false
    iotevents = false
    iotgreengrass = false
    keyspaces = false
    kinesis = false
    kinesis_analytics = false
    kms = false
    lambda = false
    lex = false
    macie = false
    mediaconnect = false
    mediaconvert = false
    mediapackage = false
    mediatailor = false
    ml = false
    mq = false
    msk = false
    mwaa = false
    nat_gateway = false
    neptune = false
    network_elb = false
    networkfirewall = false
    opsworks = false
    organizations = false
    pinpoint = false
    polly = false
    qldb = false
    ram = false
    rds = false
    rdsproxy = false
    redshift = false
    rekognition = false
    resourcegroups = false
    robomaker = false
    route53 = false
    route53resolver = false
    s3 = false
    s3storagelens = false
    sagemaker = false
    secretsmanager = false
    service_quotas = false
    servicecatalog = false
    ses = false
    shield = false
    sns = false
    sqs = false
    ssm = false
    step_functions = false
    storage_gateway = false
    swf = false
    textract = false
    transitgateway = false
    translate = false
    trusted_advisor = false
    usage = false
    vpn = false
    waf = false
    wafv2 = false
    workspaces = false
    xray = false
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
