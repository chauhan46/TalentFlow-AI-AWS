# ==========================================
# Lambda IAM Role
# ==========================================

resource "aws_iam_role" "lambda_role" {
  name = "TalentFlow-AI-Lambda-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "TalentFlow-AI-Lambda-Role"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Lambda CloudWatch Logs Permission
# ==========================================

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ==========================================
# SQS Queue
# ==========================================

resource "aws_sqs_queue" "talentflow" {
  name                       = "TalentFlow-AI-Queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  tags = {
    Name        = "TalentFlow-AI-Queue"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# SNS Topic
# ==========================================

resource "aws_sns_topic" "talentflow" {
  name = "TalentFlow-AI-Notifications"

  tags = {
    Name        = "TalentFlow-AI-Notifications"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Lambda Function
# ==========================================

resource "aws_lambda_function" "talentflow" {
  function_name = "TalentFlow-AI-API"

  role = aws_iam_role.lambda_role.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      ENVIRONMENT = "production"
      SQS_QUEUE   = aws_sqs_queue.talentflow.name
      SNS_TOPIC   = aws_sns_topic.talentflow.arn
    }
  }

  tags = {
    Name        = "TalentFlow-AI-Lambda"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic
  ]
}

# ==========================================
# API Gateway HTTP API
# ==========================================

resource "aws_apigatewayv2_api" "talentflow" {
  name          = "TalentFlow-AI-API"
  protocol_type = "HTTP"

  tags = {
    Name        = "TalentFlow-AI-API"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# API Gateway Lambda Integration
# ==========================================

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.talentflow.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.talentflow.invoke_arn
  payload_format_version = "2.0"
}

# ==========================================
# API Route
# ==========================================

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.talentflow.id
  route_key = "ANY /talentflow"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# ==========================================
# API Stage
# ==========================================

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.talentflow.id

  name = "$default"

  auto_deploy = true
}

# ==========================================
# Permission for API Gateway to invoke Lambda
# ==========================================

resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowAPIGatewayInvoke"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.talentflow.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.talentflow.execution_arn}/*/*"
}

# ==========================================
# EventBridge Rule
# ==========================================

resource "aws_cloudwatch_event_rule" "talentflow" {
  name        = "TalentFlow-AI-EventRule"
  description = "TalentFlow AI scheduled processing event"

  schedule_expression = "rate(1 day)"

  tags = {
    Name        = "TalentFlow-AI-EventRule"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# EventBridge → Lambda Target
# ==========================================

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.talentflow.name

  target_id = "TalentFlowLambda"

  arn = aws_lambda_function.talentflow.arn
}

# ==========================================
# Permission for EventBridge to invoke Lambda
# ==========================================

resource "aws_lambda_permission" "eventbridge" {
  statement_id = "AllowEventBridgeInvoke"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.talentflow.function_name

  principal = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.talentflow.arn
}

# ==========================================
# API Gateway URL Output
# ==========================================

output "talentflow_api_url" {
  description = "TalentFlow AI API Gateway URL"

  value = "${aws_apigatewayv2_stage.default.invoke_url}/talentflow"
}

# ==========================================
# S3 Bucket Output
# ==========================================

output "talentflow_s3_bucket" {
  description = "TalentFlow AI S3 bucket"

  value = aws_s3_bucket.talentflow.bucket
}

# ==========================================
# RDS Endpoint Output
# ==========================================

output "talentflow_rds_endpoint" {
  description = "TalentFlow AI RDS endpoint"

  value = aws_db_instance.talentflow.endpoint
}
