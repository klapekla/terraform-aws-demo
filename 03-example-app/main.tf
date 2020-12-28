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

# Datasources
data "aws_vpc" "this" {
  tags = {
    Project = var.project_tag
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = local.vpc_id

  tags = {
    Tier = "public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = local.vpc_id

  tags = {
    Tier = "private"
  }
}

data "aws_security_group" "bastion" {
  name = "security-group-ec2-bastion"
}

data "aws_route53_zone" "this" {
  name         = var.domain
}

# Locals
locals {
  vpc_id          = data.aws_vpc.this.id
  subnets_public  = tolist(data.aws_subnet_ids.public.ids)
  subnets_private = tolist(data.aws_subnet_ids.private.ids)
  domain_zone_id  = data.aws_route53_zone.this.zone_id
}

# Security Group for example app
resource "aws_security_group" "my_app_sg" {
  name        = "security-group-ec2-app"
  description = "Security Group for my app."
  vpc_id      = local.vpc_id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.aws_security_group.bastion.id]
  }

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "my_app_sg"
    Project = var.project_tag
  }
}

# Security Group for loadbalancer
resource "aws_security_group" "loadbalancer" {
  name        = "security-group-lb-app"
  description = "Security Group for my Loadbalancer"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "loadbalancer"
    Project = var.project_tag
  }
}

# example app
resource "aws_instance" "app" {
  count = length(local.subnets_private)

  ami             = "ami-0bd39c806c2335b95"
  instance_type   = "t2.micro"
  subnet_id       = local.subnets_private[count.index]
  security_groups = [aws_security_group.my_app_sg.id]
  user_data       = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd.x86_64
  systemctl start httpd.service
  systemctl enable httpd.service
  echo "Hello World from $(hostname -f)" > /var/www/html/index.html
  EOF

  tags = {
    Name    = "my_app_${count.index + 1}"
    Project = var.project_tag
  }
}

# loadbalancer
resource "aws_lb" "my_loadbalancer" {
  name               = "example-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer.id]
  subnets            = local.subnets_public

  tags = {
    Name    = "my_loadbalancer"
    Project = var.project_tag
  }
}

resource "aws_lb_target_group" "app" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  tags = {
    Name    = "app"
    Project = var.project_tag
  }
}

resource "aws_lb_target_group_attachment" "app" {
  count = length(aws_instance.app)

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.my_loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_route53_record" "www" {
  zone_id = local.domain_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.my_loadbalancer.dns_name
    zone_id                = aws_lb.my_loadbalancer.zone_id
    evaluate_target_health = true
  }
}