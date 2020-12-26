variable "project_tag" {
  type        = string
  description = "Name of project which will be added to each ressource"
}

variable "region" {
  type        = string
  description = "Name of AWS region"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC"
}

variable "bastion_key_name" {
  type        = string
  description = "Public Key name for access to bastion host"
}