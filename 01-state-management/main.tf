terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "my_s3_bucket_for_state_management" {
  bucket = var.s3_bucket
  acl    = "private"

  tags = {
    Name    = "my_s3_bucket_for_state_management"
    Project = var.project_tag
  }
}

resource "aws_dynamodb_table" "my_dynamodb_for_state_management" {
  name           = var.dynamodb
  hash_key       = "LockID"
  write_capacity = 1
  read_capacity  = 1


  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "my_dynamodb_for_state_management"
    Project = var.project_tag
  }
}