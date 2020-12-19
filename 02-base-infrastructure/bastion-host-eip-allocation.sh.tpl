#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  aws configure set default.region ${region}
  aws ec2 disassociate-address --public-ip ${eip_public_ip}
  aws ec2 wait instance-running — instance-id $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
  aws ec2 associate-address --instance-id "$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)" --allocation-id ${eip_allocation_id}