# this will download harmlessly whether enabled or not
resource "null_resource" "rds_enhanced_monitoring" {
  triggers = {
    script_url = "https://raw.githubusercontent.com/DataDog/datadog-serverless-functions/aws-dd-forwarder-${var.rds_enhanced_monitoring_forwarder_version}/aws/rds_enhanced_monitoring/lambda_function.py"
  }

  provisioner "local-exec" {
    command = "curl -o ${path.module}/lambda_function.py ${self.triggers.script_url}"
  }
}



data "http" "rds_enhanced_monitoring" {
  url = "https://raw.githubusercontent.com/DataDog/datadog-serverless-functions/aws-dd-forwarder-${var.rds_enhanced_monitoring_forwarder_version}/aws/rds_enhanced_monitoring/lambda_function.py"
}

data "archive_file" "rds_enhanced_monitoring" {
  type        = "zip"
#  source_file = "${path.module}/lambda_function.py"
  source {
    content = data.http.rds_enhanced_monitoring.response_body
    filename = "lambda_function.py"
  }
  output_path = "${path.module}/lambda_function.zip"

  depends_on = [null_resource.rds_enhanced_monitoring]
}

resource "aws_lambda_function" "rds_enhanced_monitoring" {
  count = var.enable_rds_enhanced_monitoring_lambda ? 1 : 0

  function_name = "${var.name}-rds-enhanced-monitoring"

  description = "Pushes RDS Enhanced metrics to Datadog."
  filename    = data.archive_file.rds_enhanced_monitoring.output_path
  runtime     = "python3.9"
  handler     = "index.lambda_handler"
  memory_size = 128
  role        = aws_iam_role.rds_enhanced_monitoring[0].arn
  timeout     = 10

  environment {
    variables = {
      DD_API_KEY_SECRET_ARN = aws_secretsmanager_secret_version.datadog.arn
    }
  }
}

data "aws_iam_policy_document" "rds_enhanced_monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret_version.datadog.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "rds_enhanced_monitoring" {
  count = var.enable_rds_enhanced_monitoring_lambda ? 1 : 0

  name_prefix = "${var.name}-rds-enhanced-monitoring"
  description = "IAM policy for Lambda to access CloudWatch Logs and SecretsManager"
  policy      = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count              = var.enable_rds_enhanced_monitoring_lambda ? 1 : 0
  name_prefix        = "${var.name}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring_assume.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.enable_rds_enhanced_monitoring_lambda ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = aws_iam_policy.rds_enhanced_monitoring[0].arn
}

resource "aws_cloudwatch_log_subscription_filter" "rds_enhanced_monitoring" {
  count = var.enable_rds_enhanced_monitoring_lambda ? 1 : 0

  name            = "${var.name}-rds-enhanced-monitoring-forwarder"
  log_group_name  = "RDSOSMetrics"
  filter_pattern  = ""
  destination_arn = aws_lambda_function.rds_enhanced_monitoring[0].arn
}
