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
    }]
  })
}

resource "aws_cloudwatch_event_rule" "pipeline_level" {
  name        = "pipeline-notify-${var.environment}"
  description = "Capture all Pipeline level execution state changes and send to SNS"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    "detail-type" = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.pipeline.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_to_sns" {
  rule = aws_cloudwatch_event_rule.pipeline_level.name
  arn  = aws_sns_topic.pipeline_alerts.arn

  input_transformer {
    input_paths = {
      pipeline  = "$.detail.pipeline"
      state     = "$.detail.state"
      execution = "$.detail.execution-id"
      start     = "$.detail.start-time"
      attempt   = "$.detail.pipeline-execution-attempt"
      region    = "$.region"

      commit    = "$.detail.execution-trigger.commit-id"
      message   = "$.detail.execution-trigger.commit-message"
      author    = "$.detail.execution-trigger.author-display-name"
      branch    = "$.detail.execution-trigger.branch-name"

      failStage  = "$.additionalAttributes.failedStage"
      failAction = "$.additionalAttributes.failedActions[0].action"
      failReason = "$.additionalAttributes.failedActions[0].additionalInformation"
    }

    input_template = <<-EOT
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      "  PIPELINE: <pipeline>"
      "  STATE:    <state>"
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      ""
      "  EXECUTION"
      "  ├─ Run ID:   <execution>"
      "  ├─ Attempt:  <attempt>"
      "  └─ Started:  <start>"
      ""
      "  COMMIT"
      "  ├─ Branch:   <branch>"
      "  ├─ Hash:     <commit>"
      "  ├─ Author:   <author>"
      "  └─ Message:  <message>"
      ""
      "  FAILURE DETAIL  (empty when state is SUCCEEDED)"
      "  ├─ Stage:   <failStage>"
      "  ├─ Action:  <failAction>"
      "  └─ Reason:  <failReason>"
      ""
      "  CONSOLE LINK"
      "  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/executions/<execution>/visualization?region=<region>"
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    EOT
  }
}

resource "aws_cloudwatch_event_rule" "stage_failed" {
  name        = "stage-failed-notify-${var.environment}"
  description = "Stage FAILED events → SNS (deeper failure detail)"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source        = ["aws.codepipeline"]
    "detail-type" = ["CodePipeline Stage Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.pipeline.name]
      state    = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "stage_to_sns" {
  rule = aws_cloudwatch_event_rule.stage_failed.name
  arn  = aws_sns_topic.pipeline_alerts.arn

  input_transformer {
    input_paths = {
      pipeline  = "$.detail.pipeline"
      stage     = "$.detail.stage"
      execution = "$.detail.execution-id"
      start     = "$.detail.start-time"
      attempt   = "$.detail.pipeline-execution-attempt"
      region    = "$.region"
    }

    input_template = <<-EOT
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      "  STAGE FAILED"
      "  Pipeline: <pipeline>"
      "  Stage:    <stage>"
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      ""
      "  ├─ Run ID:   <execution>"
      "  ├─ Attempt:  <attempt>"
      "  └─ Started:  <start>"
      ""
      "  CONSOLE LINK"
      "  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/executions/<execution>/visualization?region=<region>"
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    EOT
  }
}

resource "aws_cloudwatch_event_rule" "action_failed" {
  name        = "action-failed-notify-${var.environment}"
  description = "Action FAILED events → SNS (most granular level)"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source        = ["aws.codepipeline"]
    "detail-type" = ["CodePipeline Action Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.pipeline.name]
      state    = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "action_to_sns" {
  rule = aws_cloudwatch_event_rule.action_failed.name
  arn  = aws_sns_topic.pipeline_alerts.arn

  input_transformer {
    input_paths = {
      pipeline  = "$.detail.pipeline"
      stage     = "$.detail.stage"
      action    = "$.detail.action"
      category  = "$.detail.type.category"
      errcode   = "$.detail.error-code"
      errmsg    = "$.detail.error-detail.message"
      execution = "$.detail.execution-id"
      region    = "$.region"
    }

    input_template = <<-EOT
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      "  ACTION FAILED"
      "  Pipeline: <pipeline>"
      "  Stage:    <stage>"
      "  Action:   <action>  (<category>)"
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      ""
      "  ERROR"
      "  ├─ Code:    <errcode>"
      "  └─ Detail:  <errmsg>"
      ""
      "  Run ID: <execution>"
      ""
      "  CONSOLE LINK"
      "  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/executions/<execution>/visualization?region=<region>"
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    EOT
  }
}
