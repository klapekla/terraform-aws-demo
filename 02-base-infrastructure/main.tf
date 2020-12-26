terraform {
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
  source = "./modules/vpc"
  project_tag      = var.project_tag
  region           = var.region
}

module "bastion" {
  source           = "./modules/bastion"
  project_tag      = var.project_tag
  region           = var.region
  vpc_id           = aws_vpc.my_vpc.id
  bastion_key_name = module.iam.bastion_key_name

  depends_on       = [module.vpc]
}