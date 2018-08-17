

profile=$1
power_state=$2

case $power_state in
"start")
if [ -s $instance_id_file ] ; then
  echo "Starting instances"
instances=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=[running,stopped]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`

  if [ $profile == 'account2' ] ; then
    aws ec2 start-instances --profile $profile --instance-ids $instances >> powerstate.log 2>&1
else
    aws ec2 start-instances --instance-ids $instances >> powerstate.log 2>&1
fi
else
  echo "Instance ID file is empty. Nothing to delete"
fi
;;
"stop")
if [ -s $instance_id_file ] ; then
  echo "Stopping instances"
instances=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=[running,stopped]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`

if [ $profile == 'account2' ] ; then
    aws ec2 stop-instances --profile $profile --instance-ids $instances >> powerstate.log 2>&1
else
    aws ec2 stop-instances --instance-ids $instances >> powerstate.log 2>&1
fi
else
  echo "Instance ID file is empty. Nothing to delete"
fi
;;
esac