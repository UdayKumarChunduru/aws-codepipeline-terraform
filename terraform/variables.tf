variable "aws_region" {
  description = "AWS region where all resources are deployed"
  type        = string
}

variable "environment" {
  description = "Environment name, used to namespace all resource names"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod"
  }
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
}

variable "github_branch" {
  description = "Branch that CodePipeline monitors for changes"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the authorized AWS CodeConnections connection to GitHub"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances in the deployment group"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for application hosts"
  type        = string
  default     = "t3.micro"
}

variable "alert_email" {
  description = "Email address for pipeline failure notifications via SNS"
  type        = string
}
