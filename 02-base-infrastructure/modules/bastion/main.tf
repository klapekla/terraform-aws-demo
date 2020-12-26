# Data Sources
data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "public"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "my_ssh_sg" {
  name        = "security-group-ec2-bastion"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name    = "my_ssh_sg"
    Project = var.project_tag
  }
}

# Role for Bastion Host
resource "aws_iam_role" "my_role_for_moving_eip" {
  name = "my_role_for_moving_eip"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = {
    Name    = "my_role_for_moving_eip"
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy" "my_policy_for_moving_eip" {
  name = "my_policy_for_moving_eip"
  role = aws_iam_role.my_role_for_moving_eip.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:AssociateAddress"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

# Instance Profile
resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my_instance_profile"
  role = aws_iam_role.my_role_for_moving_eip.name
}

# Elastic IP for the Bastion Host
resource "aws_eip" "my_eip_for_bastion_host" {
  vpc = true

  tags = {
    Name    = "my_eip_for_bastion_host"
    Project = var.project_tag
  }
}

# Launch Template
locals {
  user_data_bastion = <<-EOF
  #!/bin/bash
  aws configure set default.region ${var.region}
  aws ec2 associate-address --instance-id $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${aws_eip.my_eip_for_bastion_host.id}
  EOF
}

resource "aws_launch_template" "my_launch_template_for_bastion_host" {
  name_prefix   = "bastion_host_"
  image_id      = "ami-0bd39c806c2335b95"
  instance_type = "t2.micro"
  key_name      = var.bastion_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.my_instance_profile.name
  }
  user_data = base64encode(local.user_data_bastion)

  update_default_version = true

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.my_ssh_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "my_bastion_host"
      Project = var.project_tag
    }
  }

  tags = {
    Name    = "my_launch_template_for_bastion_host"
    Project = var.project_tag
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "my_asg_for_bastion_host" {
  vpc_zone_identifier = data.aws_subnet_ids.public.ids
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.my_launch_template_for_bastion_host.id
    version = aws_launch_template.my_launch_template_for_bastion_host.latest_version
  }
}