variable "project_tag" {
  type        = string
  description = "Name of project which will be added to each ressource"
}

variable "region" {
  type        = string
  description = "Name of AWS region"
}

variable "az" {
  type        = list(string)
  description = "List of AWS availability zones"
}