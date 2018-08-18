###############################################################
## Script takes the below 2 parameters
## param 1 - AWS account profile name - "default" or "account2"
## param 2 - power state - start or stop 

## Example: 
## ./instance_power.sh default start
## ./instance_power.sh account2 stop

##
## This script can be used to power ON / OFF EC2 instances
## Script considers two AWS accounts configured with corresponding profile names "default" and "account2"
###############################################################


profile=$1
power_state=$2
instances=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=[running,stopped]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`

if [ ! -z $instances ] ; then
case $power_state in
"start")
  echo "Starting instances : $instances"
if [ $profile == 'account2' ] ; then
    aws ec2 start-instances --profile $profile --instance-ids $instances >> powerstate.log 2>&1
else
    aws ec2 start-instances --instance-ids $instances >> powerstate.log 2>&1
fi
;;
"stop")
echo "Stopping instances : $instances"
if [ $profile == 'account2' ] ; then
    aws ec2 stop-instances --profile $profile --instance-ids $instances >> powerstate.log 2>&1
else
    aws ec2 stop-instances --instance-ids $instances >> powerstate.log 2>&1
fi
;;
esac
else
  echo "Instance ID file is empty. Nothing to delete"
fi