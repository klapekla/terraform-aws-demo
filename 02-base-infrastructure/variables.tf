variable "project_tag" {
  type        = string
  description = "Name of project which will be added to each ressource"
}

variable "region" {
  type        = string
  description = "Name of AWS region"
}

variable "dns_setup" {
  type = bool
  description = "Setup new dns zone for specific domain"
  default = false
}

variable "domain" {
  type = string
  description = "Project Domain, if dns_setup is set to true"
  default = ""
}