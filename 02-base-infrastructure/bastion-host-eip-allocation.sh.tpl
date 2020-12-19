#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  aws configure set default.region ${region}
  ec2_instance_id=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
  aws ec2 wait instance-status-ok --instance-ids $ec2_instance_id
  aws ec2 associate-address --instance-id $ec2_instance_id --allocation-id ${eip_allocation_id}