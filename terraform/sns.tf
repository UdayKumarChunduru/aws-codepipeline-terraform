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
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.pipeline_alerts.arn
    }]
  })
}

resource "aws_cloudwatch_event_rule" "pipeline_events" {
  name = "pipeline-events-${var.environment}"
  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.pipeline.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "to_sns" {
  rule = aws_cloudwatch_event_rule.pipeline_events.name
  arn  = aws_sns_topic.pipeline_alerts.arn
}
