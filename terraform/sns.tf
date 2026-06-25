resource "aws_sns_topic" "pipeline_alerts" {
  name = "pipeline-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.pipeline_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_policy" "allow_events" {
  arn = aws_sns_topic.pipeline_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgePublish"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.pipeline_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "pipeline_events" {
  name        = "pipeline-events-${var.environment}"
  description = "Capture all CodePipeline execution state changes and send to SNS"
  state       = "ENABLED"
  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    "detail-type" = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.pipeline.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "to_sns" {
  rule = aws_cloudwatch_event_rule.pipeline_events.name
  arn  = aws_sns_topic.pipeline_alerts.arn
  input_transformer {
    input_paths = {
      pipeline  = "$.detail.pipeline"
      state     = "$.detail.state"
      execution = "$.detail.execution-id"
      time      = "$.time"
    }
    input_template = <<-EOT
      "Pipeline: <pipeline>"
      "State:    <state>"
      "Run ID:   <execution>"
      "Time:     <time>"
      "Console:  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view"
    EOT
  }
}
