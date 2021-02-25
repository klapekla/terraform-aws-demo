# Terraform AWS Demo

This git repository contains infrastructure as code (terraform) to deploy a common architecture to AWS. It creates a public and private network, a bastion host to connect to your private instances and an expample application behind a loadbalancer. Additionally it creates resources to manage your terraform state remotly.

## Overview

What we will build:
![aws-diagram](./assets/terraform-aws-demo.svg)

## Prerequisites

- Terraform installed on machine
- AWS account

## Usage

I devided this project in 3 parts:
1. create resources for statemanagement
2. create resources for the base infrastructure
3. create resources for an example application

In my demo AWS access_key and secret_key will be automatically loaded from ~/.aws/credentials since i have set that up previously.

### 1. Initialize for Remote Management of terraform state and state lock
Folder: 01-state-management

This folder contains files to create following ressources:
- S3 Bucket for storing the terraform state files
- DynamoDB for managing locks of terraform state files

Commands:
```bash
cd 01-state-management
terraform init
terraform plan
terraform apply
tf_state_region=$(terraform output -raw region)
tf_state_bucket=$(terraform output -raw s3_bucket)
tf_state_dynamodb_table=$(terraform output -raw dynamodb)
```

### 2. Creating infrastructure in AWS
Folder: 02-base-infrastructure

After initialization of the remote state management this folder contains files to create following resources:
- VPC
- 3 private networks (1 for each availability zone in given region)
- 3 public networks (1 for each az as well)
- Internet Gateway
- Nat Gateway in each zone
- Resilient Bastion Host in an autoscaling group
- (Optional) A dns zone

```bash
cd 02-base-infrastructure
terraform init \
    -backend-config="bucket=$tf_state_bucket" \
    -backend-config="key=terraform-aws-demo.tfstate" \
    -backend-config="region=$tf_state_region" \
    -backend-config="dynamodb_table=$tf_state_dynamodb_table"
terraform plan
terraform apply
```

### 3. Create example app in AWS
Folder: 03-example-app

This creates 3 ec2 instances and a loadbalancer as an example. Optionally a DNS record can be created as well.

```bash
cd 03-example-app
terraform init \
    -backend-config="bucket=$tf_state_bucket" \
    -backend-config="key=terraform-aws-demo-app.tfstate" \
    -backend-config="region=$tf_state_region" \
    -backend-config="dynamodb_table=$tf_state_dynamodb_table"
terraform plan
terraform apply
```