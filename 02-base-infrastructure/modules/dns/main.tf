resource "aws_route53_zone" "main" {
  name = var.domain

  tags = {
    Project = var.project_tag
  }
}