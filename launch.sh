#!/bin/bash

./cleanup.sh

#declaring an array in bash
declare -a myInsARRAY
mapfile -t myInsARRAY < <(aws ec2 run-instances --image-id $1 --count $2 --instance-type $3 --key-name $4 --security-group-ids $5 --subnet-id $6 --associate-public-ip-address --iam-instance-profile Name=$7 --user-data file://install-webserver.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")

#Displaying the created array contents
echo ${myInsARRAY[@]}

#wait until instances are launched to proceed 
aws ec2 wait instance-running --instance-ids ${myInsARRAY[@]}
echo "instances are running"

#create load balancer
ELBURL=(`aws elb create-load-balancer --load-balancer-name $8 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --security-groups $5 --subnets $6 --output=text`); 
echo $ELBURL

echo -e "\nFinished launching ELB and waiting 25 seconds"

echo -e "\n"

for i in {0..25};do echo -ne '.';sleep 1;done

echo -e "\n"

#regiter load balancer
aws elb register-instances-with-load-balancer --load-balancer-name $8 --instances ${MyInsARRAY[@]}

#health check
aws elb configure-health-check --load-balancer-name $8 --health-check Target=HTTP:80/index.html,Interval=50,UnhealthyThreshold=3,HealthyThreshold=3,Timeout=4 

#launch configuration
aws autoscaling create-launch-configuration --launch-configuration-name $9 --image-id $1 --key-name $4 --security-groups $5 -instance-type $3 --user-data file://install-webserver.sh --iam-instance-profile $7 

#create autoscaling group"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name $10 --launch-configuration-name $9 --load-balancer-names $8 --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-afa282f6 

#cloud watch matrix
ARRAY1=(`aws autoscaling put-scaling-policy --policy-name $11 --auto-scaling-group-name $10 --scaling-adjustment 1 --adjustment-type ChangeInCapacity`);

ARRAY2=(`aws autoscaling put-scaling-policy --policy-name $12 --auto-scaling-group-name $10 --scaling-adjustment 1 --adjustment-type ChangeInCapacity`);

aws cloudwatch put-metric-alarm --alarm-name AddCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 30 --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=$10" --evaluation-periods 2 --alarm-actions $ARRAY1

aws cloudwatch put-metric-alarm --alarm-name RemoveCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 10 --comparison-operator LessThanOrEqualToThreshold --dimensions "Name=AutoScalingGroupName,Value=$10" --evaluation-periods 2 --alarm-actions $ARRAY2

#create database subnet groups
aws rds create-db-subnet-group --db-subnet-group-name itmo444 --db-subnet-group-description "group for mp1" --subnet-ids subnet-7f4e4708 subnet-afa282f6  

aws rds create-db-instance --db-name users --db-instance-identifier malhoura-mp1 --db-instance-class db.t2.micro --engine MySQL --master-username malhoura --master-user-password malhoura --allocated-storage 10 --vpc-security-group-ids $5 --db-subnet-group-name itmo444 --publicly-accessible 

aws rds wait db-instance-available --db-instance-identifier malhoura-mp1 
#php ../itmo-544-444-Application-setup/setup.php
