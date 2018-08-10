#!/bin/sh
if [ -z $1 ] ; then
  echo "Missing the instance count input param. So creating one instance"
  instance_count=1
else
  instance_count=$1
fi

aws ec2 run-instances --image-id ami-28e07e50 --count $instance_count --instance-type t2.micro --key-name gs-aws-dev --security-groups ec2rhel_rule --user-data file://install.txt