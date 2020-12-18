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
    Name = "my_role_for_moving_eip"
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
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my_instance_profile"
  role = aws_iam_role.my_role_for_moving_eip.name
}