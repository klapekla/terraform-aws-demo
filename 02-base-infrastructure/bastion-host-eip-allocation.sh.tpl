#!/bin/bash
aws configure set default.region ${region}
aws ec2 disassociate-address --public-ip ${eip_public_ip}
aws ec2 associate-address --instance-id "$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)" --allocation-id ${eip_allocation_id}