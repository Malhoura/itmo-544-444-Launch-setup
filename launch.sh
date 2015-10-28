#!/bin/bash

aws ec2 run-instances --image-id ami-d05e75b8 --count 2 --instance-type t2.micro --key-name itmo-444-virtualbox --security-group-ids sg-37695650 --subnet-id subnet-7f4e4708 --associate-public-ip-address --iam-instance-profile Name=Mazen-AlHourani 
