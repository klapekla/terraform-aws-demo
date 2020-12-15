# Terraform AWS Demo

This git repo contains infrastructure as code (terraform) to deploy a standard architecture to AWS.

## Prerequisites

- Terraform installed on machine

## Usage

In my demo AWS access_key and secret_key will be automatically loaded from ~/.aws/credentials since i have set that up previously

1. Initialize for Remote Management of terraform state and state lock

Folder init-state-mangement contains iac files to create following ressources:
- S3 Bucket for storing the terraform state files
- DynamoDB for managing locks of terraform state files

Commands:
```
cd init-statement-management
terraform init
terraform plan
terraform apply
```

2. Creating infrastructure in AWS

```
terraform init
terraform plan
terraform apply
```