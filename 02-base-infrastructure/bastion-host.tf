# Elastic IP for the Bastion Host
resource "aws_eip" "my_eip_for_bastion_host" {
  vpc = true

  tags = {
    Name    = "my_eip_for_bastion_host"
    Project = var.project_tag
  }
}

# Launch Template
resource "aws_launch_template" "my_launch_template_for_bastion_host" {
  name_prefix   = "bastion_host_"
  image_id      = "ami-0bd39c806c2335b95"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.my_instance_profile.name
  }
  user_data     = base64encode(templatefile("bastion-host-eip-allocation.sh.tpl", {region = var.region , eip_public_ip = aws_eip.my_eip_for_bastion_host.public_ip , eip_allocation_id = aws_eip.my_eip_for_bastion_host.id }))
  update_default_version = true

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.my_ssh_sg.id]
  }

  tags = {
    Name    = "my_launch_template_for_bastion_host"
    Project = var.project_tag
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "my_asg_for_bastion_host" {
  vpc_zone_identifier = aws_subnet.my_public_subnets[*].id
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.my_launch_template_for_bastion_host.id
    version = aws_launch_template.my_launch_template_for_bastion_host.latest_version
  }
}