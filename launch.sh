#!/bin/bash


#create database subnet groups
#this command might not be important
#aws rds create-db-subnet-group --db-subnet-group-name itmo444 --db-subnet-group-description "group for mp1" --subnet-ids subnet-7f4e4708 subnet-afa282f6

#aws rds create-db-instance --db-name malhouradb --db-instance-identifier malhoura-mp1 --db-instance-class db.t2.micro --engine MySQL --master-username malhoura --master-user-password malhoura --allocated-storage 10 --vpc-security-group-ids sg-37695650 --db-subnet-group-name itmo444 --publicly-accessible

#aws rds wait db-instance-available --db-instance-identifier malhoura-mp1
#echo "Successfully launched RDS instance!"


#declaring an array in bash
declare -a myInsARRAY
mapfile -t myInsARRAY < <(aws ec2 run-instances --image-id ami-d05e75b8 --count $1 --instance-type t2.micro --key-name $2 --security-group-ids sg-37695650 --subnet-id subnet-afa282f6 --associate-public-ip-address --iam-instance-profile Name=phpRole --user-data file://install-webserver.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")

#Displaying the created array contents
echo ${myInsARRAY[@]}

#wait until instances are launched to proceed 
aws ec2 wait instance-running --instance-ids ${myInsARRAY[@]}
echo "instances are running"

#create load balancer
aws elb create-load-balancer --load-balancer-name $3 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --security-groups sg-37695650 --subnets subnet-afa282f6 
echo $3

echo -e "\nFinished launching ELB and waiting 25 seconds"

echo -e "\n"

for i in {0..25};do echo -ne '.';sleep 1;done

echo -e "\n"

#regiter load balancer
aws elb register-instances-with-load-balancer --load-balancer-name $3 --instances ${MyInsARRAY[@]}

#health check
aws elb configure-health-check --load-balancer-name $3 --health-check Target=HTTP:80/index.php,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3 

#launch configuration
aws autoscaling create-launch-configuration --launch-configuration-name malhoura-launch-config --image-id ami-d05e75b8 --key-name $2 --security-groups sg-37695650 --instance-type t2.micro --user-data file://install-webserver.sh --iam-instance-profile phpRole 

#create autoscaling group
aws autoscaling create-auto-scaling-group --auto-scaling-group-name malhoura-auto-scaling --launch-configuration-name malhoura-launch-config --load-balancer-names $3 --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-afa282f6


#cloud watch matrix
aws cloudwatch put-metric-alarm --alarm-name ScaleUp --alarm-description "ScaleUP when CPU >= 30" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 30 --comparison-operator GreaterThanThreshold --evaluation-periods 2 --unit Percent

aws cloudwatch put-metric-alarm --alarm-name ScaleDown --alarm-description "ScaleDown when CPU <= 10 " --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 10 --comparison-operator LessThanThreshold --evaluation-periods 2 --unit Percent

#create sns topic
SNSARN =(`aws sns create-topic --name mp2`)
aws sns set-topic-attributes --topic-arn $SNSARN --attribute-name DisplayName --attribute-value mp2
aws sns subscribe --topic-arn $SNSARN --protocol sms --notification-endpoint 13128885475 
