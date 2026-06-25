output "pipeline_name" {
  value = aws_codepipeline.pipeline.name
}

output "instance_public_ips" {
  value = aws_instance.app[*].public_ip
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "alerts_topic_arn" {
  value = aws_sns_topic.pipeline_alerts.arn
}
