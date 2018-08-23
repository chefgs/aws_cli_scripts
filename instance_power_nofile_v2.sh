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
case $power_state in
"start")
  instances_off=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=[stopped]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`
  if [ ! -z "$instances_off" ] ; then
    echo "Starting instances : $instances_off"
    aws ec2 start-instances --profile $profile --instance-ids $instances_off >> powerstate.log 2>&1
  else
    echo "Nothing to turn ON"
  fi
;;
"stop")
  instances_on=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=[running]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`
  if [ ! -z "$instances_on" ] ; then
  echo "Stopping instances : $instances_on"
  aws ec2 stop-instances --profile $profile --instance-ids $instances_on >> powerstate.log 2>&1
  else
    echo "Nothing to turn OFF"
  fi
;;
esac
