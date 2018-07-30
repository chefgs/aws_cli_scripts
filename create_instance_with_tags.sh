###############################################################
## Script needs the below 2 parameters
## param 1 - instance_count - count of 'n' number of instances 
## param 2 - AWS account profile name - "default" or "account2"

## Example: 
## ./create_instance_with_tags.sh 1 default
## ./create_instance_with_tags.sh 1 account2

##
## This script can be used to create instances with 2 tags/values
## Script considers two AWS accounts 
## Those accounts configured with corresponding profile names "default" and "account2"
###############################################################

if [ -z $1 ] ; then
  echo "Missing the instance count input param. So creating one instance"
  instance_count=1
else
  instance_count=$1
fi

profile=$2

if [ $profile == 'account2' ] ; then
echo "Creating Instances in account2"
aws ec2 run-instances --profile $profile --image-id ami-6f68cf0f --count $instance_count --instance-type t2.micro --key-name dev_env_key --security-groups ec2_rhel_rule --tag-specifications 'ResourceType=instance,Tags=[{Key=Env,Value=Dev},{Key=vmtag1,Value=vmtagvalue1}]' | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' > instance_ids_$profile.txt
echo "Created Instance IDs: `cat instance_ids_$profile.txt`"
else
echo "Creating Instances in default account"
aws ec2 run-instances --image-id ami-6f68cf0f --count $instance_count --instance-type t2.micro --key-name test_env_key --security-groups ec2_rhel_rule --tag-specifications 'ResourceType=instance,Tags=[{Key=Env,Value=Dev},{Key=vmtag1,Value=vmtagvalue1}]' | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' > instance_ids_$profile.txt

echo "Created Instance IDs: `cat instance_ids_$profile.txt`"
fi
