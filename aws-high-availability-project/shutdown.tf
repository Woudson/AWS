provider "aws" {
  region = "sa-east-1"
}

variable "instance_id" {
  description = "i-094d2c604d60826aa"
  type        = string
}

resource "aws_iam_role" "scheduler_ssm_role" {
  name = "scheduler-ssm-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "scheduler_ssm_policy" {
  name = "scheduler-ssm-ec2-policy"
  role = aws_iam_role.scheduler_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution"
        ]
        Resource = [
          "arn:aws:ssm:sa-east-1::automation-definition/AWS-StartEC2Instance:$DEFAULT",
          "arn:aws:ssm:sa-east-1::automation-definition/AWS-StopEC2Instance:$DEFAULT"
        ]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.scheduler_ssm_role.arn
      }
    ]
  })
}

resource "aws_scheduler_schedule" "start_ec2" {
  name                         = "start-ec2-office-hours"
  group_name                   = "default"
  schedule_expression          = "cron(0  ? * MON-FRI *)"
  schedule_expression_timezone = "America/Sao_Paulo"
  state                        = "ENABLED"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.scheduler_ssm_role.arn

    input = jsonencode({
      DocumentName = "AWS-StartEC2Instance"
      Parameters = {
        InstanceId = [var.instance_id]
      }
    })
  }
}

resource "aws_scheduler_schedule" "stop_ec2" {
  name                         = "stop-ec2-office-hours"
  group_name                   = "default"
  schedule_expression          = "cron(0 19 ? * MON-FRI *)"
  schedule_expression_timezone = "America/Sao_Paulo"
  state                        = "ENABLED"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.scheduler_ssm_role.arn

    input = jsonencode({
      DocumentName = "AWS-StopEC2Instance"
      Parameters = {
        InstanceId = [var.instance_id]
      }
    })
  }
}