# TODO: allow version specification
# right now you can't use variables in a module's source so we'll have to use the external provider or git submodules
module "rds_enhanced_monitoring_lambda_code" {
  source = "git::https://github.com/DataDog/datadog-serverless-functions.git?ref=aws-dd-forwarder-3.83.0"
}

##########################################
# this is basically copied from https://github.com/DataDog/datadog-serverless-functions/blob/master/aws/rds_enhanced_monitoring/rds-enhanced-sam-template.yaml
# because their documentation says to use the SAM repo which points to an out-of-date version
# and because we load the API key differently
##########################################

resource "aws_cloudformation_stack" "rds_enhanced_monitoring_lambda" {
  count = var.install_rds_enhanced_monitoring_lambda ? 1 : 0

  name         = "${var.name}-rds-enhanced-monitoring-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  depends_on   = [aws_s3_object.rds_enhanced_monitoring_lambda_code]

  template_body = <<EOF
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: 'Pushes RDS Enhanced metrics to Datadog.'
Resources:
  rdslambdaddfunction:
    Type: 'AWS::Serverless::Function'
    Properties:
      Description: Pushes RDS Enhanced metrics to Datadog.
      InlineCode: |
        ${indent(8, file("${path.module}.rds_enhanced_monitoring_lambda_code/aws/rds_enhanced_monitoring/lambda_function.py"))}
      Environment:
        Variables:
          DD_API_KEY_SECRET_ARN: '${aws_secretsmanager_secret_version.datadog.arn}'
      Events:
        RDSEnhancedMetrics:
          Type: CloudWatchLogs
          Properties:
            LogGroupName: RDSOSMetrics
            FilterPattern: ""
      Handler: index.lambda_handler
      MemorySize: 128
      Runtime: python3.9
      Policies:
        - AWSLambdaExecute
        - AWSSecretsManagerGetSecretValuePolicy:
            SecretArn: '${aws_secretsmanager_secret_version.datadog.arn}'
      Timeout: 10
EOF
}
