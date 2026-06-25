# AWS CI/CD Pipeline with Terraform
A complete CI/CD pipeline built using AWS native DevOps services and provisioned entirely with Terraform. The pipeline automatically builds, tests, and deploys a Python Flask application to EC2 instances using AWS CodePipeline, CodeBuild, and CodeDeploy, with automated rollback and failure notifications.

## Architecture Overview
The deployment workflow consists of the following stages:

1. **Source** – AWS CodePipeline monitors a GitHub repository branch through AWS CodeConnections (CodeStar Connection).
2. **Build** – AWS CodeBuild executes `buildspec.yml`, installs dependencies, performs validation, and packages deployment artifacts.
3. **Deploy** – AWS CodeDeploy retrieves the application bundle from S3 and executes deployment lifecycle hooks defined in `appspec.yml`.
4. **Monitoring & Rollback** – CloudWatch alarms monitor EC2 instance health. If a deployment causes unhealthy instances, CodeDeploy automatically rolls back to the last successful revision.
5. **Notifications** – EventBridge captures pipeline failures and publishes alerts to an SNS topic with email subscriptions.

## Deployment Flow
```text
GitHub
   │
   ▼
CodePipeline
   │
   ▼
CodeBuild
   │
   ▼
S3 Artifact Store
   │
   ▼
CodeDeploy
   │
   ▼
EC2 Instances
   │
   ▼
CloudWatch Alarm
   │
   └──► Automatic Rollback

EventBridge ──► SNS ──► Email Alerts
```

## Repository Structure
```text
.
├── README.md
├── appspec.yml
├── buildspec.yml
├── app/
│   ├── app.py
│   └── requirements.txt
├── scripts/
│   ├── install_dependencies.sh
│   ├── start_application.sh
│   ├── stop_application.sh
│   └── validate_service.sh
└── terraform/
    ├── cloudwatch.tf
    ├── codebuild.tf
    ├── codedeploy.tf
    ├── codepipeline.tf
    ├── dev.tfvars
    ├── ec2.tf
    ├── iam.tf
    ├── outputs.tf
    ├── prod.tfvars
    ├── providers.tf
    ├── s3.tf
    ├── sns.tf
    ├── user-data.sh
    └── variables.tf
```

## AWS Services Used
| Service | Purpose |
|----------|----------|
| CodePipeline | CI/CD orchestration |
| CodeBuild | Build and packaging |
| CodeDeploy | Application deployment |
| EC2 | Application hosting |
| S3 | Artifact storage |
| IAM | Roles and permissions |
| CloudWatch | Monitoring and alarms |
| SNS | Email notifications |
| EventBridge | Failure event routing |
| CodeConnections | GitHub integration |

## Prerequisites
Before deploying the infrastructure, ensure you have:

- Terraform v1.5.0 or later
- AWS CLI installed and configured
- AWS credentials with permissions to create the required resources
- A GitHub repository containing this project
- An authorized AWS CodeConnections connection to GitHub

> **Important:** Terraform can create the CodeConnections resource but cannot complete the GitHub authorization flow. The connection must be authorized manually in the AWS Console.

## Configuration
Environment-specific settings are stored in Terraform variable files.

### Variables
| Variable | Description |
|-----------|-------------|
| `environment` | Environment name (`dev` or `prod`) |
| `github_repo` | GitHub repository in `owner/repo` format |
| `github_branch` | Branch monitored by the pipeline |
| `codestar_connection_arn` | ARN of the authorized CodeConnections resource |
| `instance_count` | Number of EC2 instances |
| `instance_type` | EC2 instance type |
| `alert_email` | Email address for pipeline notifications |

### Example
```hcl
environment             = "dev"
github_repo             = "username/aws-codepipeline-terraform"
github_branch           = "main"
codestar_connection_arn = "arn:aws:codeconnections:region:account-id:connection/xxxx"
instance_count          = 1
instance_type           = "t3.micro"
alert_email             = "mail@gmail.com"
```

> **Note:** The value of `github_repo` is case-sensitive and must exactly match the GitHub repository path.

## Setup
### 1. Create and Authorize GitHub Connection
1. Open the AWS Console.
2. Navigate to **Developer Tools → Connections**.
3. Create a GitHub connection.
4. Complete the authorization process.
5. Copy the generated connection ARN.
6. Add the ARN to your `.tfvars` file.

### 2. Deploy Infrastructure
#### Development
```bash
cd terraform

terraform init

terraform plan -var-file=dev.tfvars

terraform apply -var-file=dev.tfvars
```

#### Production
```bash
terraform plan -var-file=prod.tfvars

terraform apply -var-file=prod.tfvars
```

### 3. Confirm SNS Subscription
After deployment:

1. Check the inbox for the email specified in `alert_email`.
2. Open the SNS confirmation email.
3. Click the confirmation link.

Without confirmation, pipeline failure notifications will not be delivered.

## Local Application Testing
Run the Flask application locally:

```bash
cd app

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt

python app.py
```

The application will be available at:

```text
http://localhost:8000
```

## Deployment Lifecycle Hooks
CodeDeploy executes the following scripts during deployment:

| Script | Purpose |
|----------|----------|
| `install_dependencies.sh` | Install Python and application dependencies |
| `stop_application.sh` | Stop the currently running application |
| `start_application.sh` | Configure and start the systemd service |
| `validate_service.sh` | Verify application health endpoint |

## Features
- Infrastructure as Code (Terraform)
- GitHub integration via AWS CodeConnections
- Automated build and deployment pipeline
- EC2 deployment using CodeDeploy
- Rolling deployments with lifecycle hooks
- CloudWatch monitoring and alarms
- Automatic rollback on failed deployments
- SNS email notifications
- Separate development and production configurations
- Least-privilege IAM roles and policies

## Cleanup
To remove all provisioned AWS resources and avoid ongoing charges:

### Development
```bash
cd terraform

terraform destroy -var-file=dev.tfvars
```

### Production

```bash
terraform destroy -var-file=prod.tfvars
```
