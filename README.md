# Terraform AWS Demo

This git repo contains infrastructure as code (terraform) to deploy a standard architecture to AWS.

## Prerequisites

- Terraform installed on machine

## Usage

In my demo AWS access_key and secret_key will be automatically loaded from ~/.aws/credentials since i have set that up previously

### 1. Initialize for Remote Management of terraform state and state lock
Folder: 01-state-management

This folder contains iac files to create following ressources:
- S3 Bucket for storing the terraform state files
- DynamoDB for managing locks of terraform state files

Commands:
```
cd 01-state-management
terraform init
terraform plan
terraform apply
```

### 2. Creating infrastructure in AWS
Folder: 02-base-infrastructure

```
cd 02-base-infrastructure
terraform init \
    -backend-config="bucket=terraform-state-wuoes-20201215" \
    -backend-config="key=terraform-aws-demo.tfstate" \
    -backend-config="region=eu-central-1" \
    -backend-config="dynamodb_table=terraform-state-lock"
terraform plan
terraform apply
```