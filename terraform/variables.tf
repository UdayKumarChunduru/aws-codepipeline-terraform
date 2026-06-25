variable "aws_region" {
  description = "Region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name, dev or prod, used in resource names"
  type        = string
}

variable "github_repo" {
  description = "Source repository as owner/repo"
  type        = string
}

variable "github_branch" {
  description = "Branch that triggers the pipeline"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the authorized CodeStar connection to GitHub"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances in the deployment group"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "alert_email" {
  description = "Email address subscribed to pipeline failure notifications"
  type        = string
}
