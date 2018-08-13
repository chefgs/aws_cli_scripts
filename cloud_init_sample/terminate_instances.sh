#############################################
# Script usage: Provide profile name as input arg
# ./terminate_instances.sh
#############################################
instances=`aws ec2 describe-instances --filter Name=tag-key,Values=DEMO | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | xargs`

echo "Terminating the following VMs: $instances"

aws ec2 terminate-instances --instance-ids $instances >> terminate.log
