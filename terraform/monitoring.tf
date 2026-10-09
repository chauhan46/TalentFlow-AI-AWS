# ==========================================
# EC2 Auto Scaling CPU Alarm
# ==========================================

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "TalentFlow-AI-EC2-High-CPU"
  alarm_description   = "Alerts when TalentFlow AI EC2 Auto Scaling instances have high CPU usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.talentflow.name
  }

  alarm_actions = [
    aws_sns_topic.talentflow.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "TalentFlow-AI-EC2-CPU-Alarm"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# ALB 5xx Error Alarm
# ==========================================

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "TalentFlow-AI-ALB-5XX"
  alarm_description   = "Alerts when the TalentFlow AI ALB target group returns 5xx errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5

  dimensions = {
    LoadBalancer = aws_lb.talentflow.arn_suffix
    TargetGroup  = aws_lb_target_group.talentflow.arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.talentflow.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "TalentFlow-AI-ALB-5XX-Alarm"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# RDS CPU Alarm
# ==========================================

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "TalentFlow-AI-RDS-High-CPU"
  alarm_description   = "Alerts when the TalentFlow AI RDS database has high CPU usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.talentflow.identifier
  }

  alarm_actions = [
    aws_sns_topic.talentflow.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "TalentFlow-AI-RDS-CPU-Alarm"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# Lambda Error Alarm
# ==========================================

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "TalentFlow-AI-Lambda-Errors"
  alarm_description   = "Alerts when TalentFlow AI Lambda reports execution errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.talentflow.function_name
  }

  alarm_actions = [
    aws_sns_topic.talentflow.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "TalentFlow-AI-Lambda-Error-Alarm"
    Project     = "TalentFlow-AI"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
