
variable "install_rds_enhanced_monitoring_lambda" {
  default = true
}

module "rds_enhanced_monitoring_lambda_code" {
  source = "https://github.com/DataDog/datadog-serverless-functions.git?ref=aws-dd-forwarder-3.83.0"
}

# see https://github.com/DataDog/datadog-serverless-functions/blob/master/aws/rds_enhanced_monitoring/rds-enhanced-sam-template.yaml
resource "aws_cloudformation_stack" "rds_enhanced_monitoring_lambda" {
  count = var.install_rds_enhanced_monitoring_lambda ? 1 : 0

  name         = "${var.name}-rds-enhanced-monitoring-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  depends_on   = [module.rds_enhanced_monitoring_lambda_code]

  template_body = <<EOF
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: 'Pushes RDS Enhanced metrics to Datadog.'
Resources:
  rdslambdaddfunction:
    Type: 'AWS::Serverless::Function'
    Properties:
      Description: Pushes RDS Enhanced metrics to Datadog.
      Environment:
        Variables:
          DD_API_KEY_SECRET_ARN: '${aws_secretsmanager_secret_version.datadog.arn}'
      Handler: ${path.module}/.terraform/moudles/rds_enhanced_monitoring_lambda_code/aws/rds_enhanced_monitoring/lambda_function.lambda_handler
      MemorySize: 128
      Policies:
        - AWSSecretsManagerGetSecretValuePolicy:
            SecretArn: '${aws_secretsmanager_secret_version.datadog.arn}'
          Runtime: python3.9
      Timeout: 10
EOF

  #   provisioner "local-exec" {
  #     command = "git clone --depth 1 --branch aws-dd-forwarder-3.83.0  https://github.com/DataDog/datadog-serverless-functions.git"
  #   }
}
