terraform {
  backend "s3" {
    bucket         = "terraform-state-wuoes-20201215"
    key            = "terraform-aws-demo.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
  }
}