#!/bin/bash

mapfile -t myInsARRAY < <{aws ec2 run-instances --image-id ami-d05e75b8 --count i --instance-type t2.micro --key-name itmo-444-virtualbox --security-group-ids sg-37695650 --subnet-id subnet-7f4e4708 --associate-public-ip-address --iam-instance-profile Name=Mazen-AlHourani --user-data file://itmo-544-444-Environment-setup/install-env.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g"} 
