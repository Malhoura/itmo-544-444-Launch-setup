#!/bin/bash

./cleanup.sh

#declaring an array in bash
declare -a myInsARRAY
mapfile -t myInsARRAY < <(aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name itmo-444-virtualbox --security-group-ids sg-37695650 --subnet-id subnet-afa282f6 --associate-public-ip-address --iam-instance-profile Name=phpRole --user-data file://install-webserver.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")

#Displaying the created array contents
echo ${myInsARRAY[@]}

#wait until instances are launched to proceed 
aws ec2 wait instance-running --instance-ids ${myInsARRAY[@]}
echo "instances are running"

#create load balancer
ELBURL=(`aws elb create-load-balancer --load-balancer-name $2 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --security-groups sg-37695650 --subnets subnet-afa282f6 --output=text`); 
echo $ELBURL

echo -e "\nFinished launching ELB and waiting 25 seconds"

echo -e "\n"

for i in {0..25};do echo -ne '.';sleep 1;done

echo -e "\n"

#regiter load balancer
aws elb register-instances-with-load-balancer --load-balancer-name $2 --instances ${MyInsARRAY[@]}

#health check
aws elb configure-health-check --load-balancer-name $2 --health-check Target=HTTP:80/index.html,Interval=50,UnhealthyThreshold=3,HealthyThreshold=3,Timeout=4 

#launch configuration

#aws autoscaling create-launch-configuration --launch-configuration-name malhoura-launch-config --image-id ami-d05e75b8 --key-name itmo-444-virtualbox --security-groups sg-37695650 --instance-type t2.micro --user-data file://install-webserver.sh --iam-instance-profile phpRole

#create autoscaling group"

#aws autoscaling create-auto-scaling-group --auto-scaling-group-name malhoura-auto-scaling-group --launch-configuration-name malhoura-launch-config --load-balancer-names $2 --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-afa282f6 

#cloud watch matrix
#ARRAY1=(`aws autoscaling put-scaling-policy --policy-name policy-1 --auto-scaling-group-name itmo-544-444-autoscaling-group --scaling-adjustment 1 --adjustment-type ChangeInCapacity`);

#ARRAY2=(`aws autoscaling put-scaling-policy --policy-name policy-2 --auto-scaling-group-name itmo-544-444-autoscaling-group --scaling-adjustment 1 --adjustment-type ChangeInCapacity`);

#aws cloudwatch put-metric-alarm --alarm-name AddCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 30 --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=itmo-544-444-autoscaling-group" --evaluation-periods 2 --alarm-actions $ARRAY1

#aws cloudwatch put-metric-alarm --alarm-name RemoveCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 10 --comparison-operator LessThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=itmo-544-444-autoscaling-group" --evaluation-periods 2 --alarm-actions $ARRAY2

#create database subnet groups
#aws rds create-db-subnet-group --db-subnet-group-name itmo444 --db-subnet-group-description "group for mp1" --subnet-ids subnet-7f4e4708 subnet-afa282f6  

#aws rds create-db-instance --db-name users --db-instance-identifier malhoura-mp1 --db-instance-class db.t2.micro --engine MySQL --master-username malhoura --master-user-password malhoura --allocated-storage 10 --vpc-security-group-ids sg-37695650 --db-subnet-group-name itmo444 --publicly-accessible 

#aws rds wait db-instance-available --db-instance-identifier malhoura-mp1 
#php ../itmo-544-444-Application-setup/setup.php
