#!/bin/bash

#declaring an array in bash
declare -a myInsARRAY
mapfile -t myInsARRAY < <(aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name itmo-444-virtualbox --security-group-ids sg-37695650 --subnet-id subnet-7f4e4708 --associate-public-ip-address --iam-instance-profile Name=Mazen-AlHourani --user-data file://itmo-544-444-Environment-setup/install-env.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")

#Displaying the created array contents
echo ${myInsARRAY[@]}

#wait until instances are launched to proceed 
aws ec2 wait instance-running --instance-ids ${myInsARRAY[@]}
echo "instances are running"

#create load balancer
ELBURL=('aws elb create-load-balancer --load-balancer-name $2 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --security-groups sg-37695650 --subnets subnet-7f4e4708 --output=text'); 
echo $ELBURL

#regiter load balancer
aws elb register-instances-with-load-balancer --load-balancer-name $2 --instances ${MyInsARRAY[@]}

#health check
aws elb configure-health-check --load-balancer-name $2 --health-check Target=HTTP:80/index.html,interval=30,unhealthyThreshold=2,HealthyThreshold=2,Timeout=3

#launch configuration
aws autoscaling create-launch-configuration --launch-configuration-name itmo-544-444-launch-config --image-id ami-d05e75b8 --key-name itmo-444-virtualbox --security-groups sg-37695650 --instance-type t2.micro --user-data file://itmo-544-444-Environment-setup/install-env.sh --iam-instance-profile Mazen-AlHourani
