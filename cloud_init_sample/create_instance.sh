#!/bin/sh
###############################################
# Script will be used to create 'n' number instance in AWS.
# Arg 1: instance_count: number of instance to be created
# Arg 2: Security group name: SG rule with port 22 inbound access. It is required to connect VM using putty
# Arg 3: Key pair name: Required for accessing the VM using putty 
# Usage: ./create_instance.sh 1 sg_name key_name
###############################################
if [ -z $1 ] ; then
  echo "Missing the instance count input param. So creating one instance"
  instance_count=1
else
  instance_count=$1
fi
sg_name=$2
key_name=$3

# aws resource-groups create-group --name demo-rg$RANDOM --resource-query '{"Type":"TAG_FILTERS_1_0","Query":"{\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Purpose\",\"Values\":[\"Demo\"]}]}"}'

aws ec2 run-instances --image-id ami-28e07e50 --count $instance_count --instance-type t2.micro --key-name $key_name --security-groups $sg_name --user-data file://install.txt --tag-specifications 'ResourceType=instance,Tags=[{Key=DEMO,Value=Instance}]'
