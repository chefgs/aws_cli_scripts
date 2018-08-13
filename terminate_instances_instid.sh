###############################################################
## Script needs the below 2 parameters
## param 1 - instance_id_file - Name of the text file contains the instance IDs 
## param 2 - AWS account profile name - "default" or "account2"

## Example: 
## ./terminate_instances.sh 1 default
## ./terminate_instances.sh 1 account2

##
## This script can be used to TERMINATE the instances mentioned in the instance_id text file 
## Script considers two AWS accounts 
## Those accounts configured with corresponding profile names "default" and "account2"
###############################################################

if [ -z $1 ] ; then
  echo "Missing the name of instance id text file as input"
  exit 0
else
  instance_id_file=$1
  echo "Instance ID file param passed: Filename: $instance_id_file"
fi

profile=$2

if [ -s $instance_id_file ] ; then
  echo "Deleting instances"
  instance_ids=`cat $instance_id_file | xargs`
if [ $profile == 'account2' ] ; then
    aws ec2 terminate-instances --profile $profile --instance-ids $instance_ids >> terminate.log 2>&1
else
    aws ec2 terminate-instances --instance-ids $instance_ids >> terminate.log 2>&1
fi
else
  echo "Instance ID file is empty. Nothing to delete"
fi
