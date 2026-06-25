resource "aws_cloudwatch_metric_alarm" "instance_health" {
  alarm_name          = "flask-app-health-${var.environment}"
  alarm_description   = "Status check failures on the deployment canary instance"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.app[0].id
  }
}
