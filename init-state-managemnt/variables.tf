variable "project_tag" {
  type        = string
  description = "Name of project which will be added to each ressource"
}

variable "region" {
  type        = string
  description = "Name of AWS region"
}

variable "s3_bucket" {
  type = string
  description = "name of s3 bucket for storing terraform state file"
}

variable "dynamodb" {
  type = string
  description = "Name of dynamodb to store terraform state lock file"
}