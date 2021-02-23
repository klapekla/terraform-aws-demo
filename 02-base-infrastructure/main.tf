terraform {
  required_version = "~> 0.14.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "iam" {
  source                       = "./modules/iam"
  external_public_key_location = "~/.ssh/id_rsa.pub"
  internal_public_key_location = "~/.ssh/id_rsa.pub"
}

module "vpc" {
  source      = "./modules/vpc"
  project_tag = var.project_tag
  region      = var.region
}

module "dns" {
  count = var.dns_setup ? 1 : 0

  source = "./modules/dns"
  project_tag = var.project_tag
  domain = var.domain
}

module "bastion" {
  source           = "./modules/bastion"
  project_tag      = var.project_tag
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  bastion_key_name = module.iam.bastion_key_name
}