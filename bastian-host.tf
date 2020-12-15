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
  name_prefix   = "bastion_host"
  image_id      = "ami-0bd39c806c2335b95"
  instance_type = "t2.micro"
  user_data     = filebase64(templatefile("bastion-host-eip-allocation.sh.tpl", {eip_public_ip = aws_eip.my_eip_for_bastion_host.public_ip , eip_allocation_id = aws_eip.my_eip_for_bastion_host.id }))

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
    version = "$Latest"
  }
}