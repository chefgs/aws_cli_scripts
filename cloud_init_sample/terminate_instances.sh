#############################################
# Script usage: Provide profile name as input arg
# ./terminate_all_instances.sh default
#############################################
profile=$1
instances=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=[running,stopped]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`

echo "Terminating the following VMs: $instances"

aws ec2 terminate-instances --profile $profile --instance-ids $instances >> terminate.log
