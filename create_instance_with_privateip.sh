###############################################################
## Script needs the below 2 parameters
## param 1 - instance_count - count of 'n' number of instances 
## param 2 - AWS account profile name - "default" or "account2"

## Example: 
## ./create_instance_with_privateip.sh 1 default
## ./create_instance_with_privateip.sh 1 account2

##
## This script can be used to create instances attached with 1 privateIP
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

if [ $profile == 'default' ] ; then
echo "Creating Instances in default account"
filename="instance_ids_$RANDOM.txt"
# for i in {0..$instance_count}
for ((i=1;i <= $instance_count;i+=1))
do
aws ec2 run-instances --image-id ami-6f68cf0f --count 1 --instance-type t2.micro --key-name test_env --subnet-id subnet-e545f5ac --secondary-private-ip-address-count 1 | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' >> $filename
echo "Instance $i "
done
echo "Created Instance IDs: `cat $filename`"
else
echo "Creating Instances in account2"
filename="instance_ids_$RANDOM.txt"
# for i in {0..$instance_count}
for ((i=1;i <= $instance_count;i+=1))
do
aws ec2 run-instances --profile $profile --image-id ami-6f68cf0f --count 1 --instance-type t2.micro --key-name test_env --subnet-id subnet-e545f5ac --secondary-private-ip-address-count 1 | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' >> $filename
echo "Instance $i "
done
echo "Created Instance IDs: `cat $filename`"
fi
