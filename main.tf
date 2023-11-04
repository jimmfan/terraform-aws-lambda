data "aws_iam_policy_document" "lambda_policy_document" {
  # CloudWatch Logs Policy
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  # X-Ray Policy
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]
    resources = [
      "*",
    ]
  }

  # Creates DynamoDB policy if var.dynamodb_table_name is specified
  dynamic "statement" {
    for_each = var.dynamodb_table_name == "" ? [] : [1]
    content {
      effect = "Allow"
      actions = [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      resources = [
        "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.dynamodb_table_name}",
      ]
    }
  }

  version = "2012-10-17"
}

# IAM policy for lambda
resource "aws_iam_policy" "iam_lambda_policy" {
  name_prefix = "${var.lambda_name}-iam_policy"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role" "lambda" {
  name_prefix = "${var.lambda_name}-iam_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

# Policy Attachment on the role.
resource "aws_iam_role_policy_attachment" "attach_policy_role" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.iam_lambda_policy.arn
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${var.lambda_name}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda.arn
  handler          = var.handler
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = var.runtime
  layers           = var.layers
  timeout          = var.timeout
  memory_size      = var.memory_size

  # Publish if provisioned_concurrent_executions > 0 or if publish is explicitly set to true
  publish = var.provisioned_concurrent_executions > 0 || var.publish

  # Map of environment variables accessible from the function during execution.
  environment {
    variables = var.environment_variables
  }

  tracing_config {
    mode = "Active"
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.attach_policy_role,
    aws_cloudwatch_log_group.lambda_log_group
  ]

}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count             = var.log_retention_in_days != null ? 1 : 0
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, var.cloudwatch_log_tags)
}

resource "aws_lambda_provisioned_concurrency_config" "provisioned_concurrency_for_lambda" {
  # Provision this resource if provisioned_concurrent_executions is provided
  count                             = var.provisioned_concurrent_executions > 0 ? 1 : 0
  function_name                     = aws_lambda_function.lambda.function_name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  qualifier                         = aws_lambda_function.lambda.version
}