# AWS CLI script for creating EC2 EBS Volume for all the instances available in the default AWS account

profile=$1

aws.cmd ec2 describe-instances --filters "Name=instance-state-name,Values=[running]" --profile $profile | grep -i "InstanceId" | awk -F'\"' '{ print  $4 }' | while read instance_id
do
echo "Processing snap-shot creation for instance $instance_id"
# Stop instances
echo "Stop instance"
aws.cmd ec2 stop-instances --profile $profile --instance-ids $instance_id
while [ "$instance_state" != "stopped" ]
do
instance_state=`aws.cmd ec2 describe-instances --profile $profile --instance-ids $instance_id | grep -A 3 "State" | grep -i "Name" | awk -F'\"' '{ print  $4 }'`
echo "Waiting to instance state changed to STOPPED"
done

echo "Get Volume ID not encrypted"
volume=`aws.cmd ec2 describe-instances --profile $profile --filters "Name=instance-id,Values=$instance_id" | grep -A 6 "sda1" | grep -i "VolumeID" | awk -F'\"' '{ print  $4 }'`
echo $volume

echo "Create snapshot of Volume"
snapshot_id=`aws.cmd ec2 create-snapshot --profile $profile --volume-id $volume | grep -i "SnapshotId" | awk -F'\"' '{ print $4 }'`
echo $snapshot_id

while [ "$snapshot1_status" != "completed" ]
do
snapshot1_status=`aws.cmd ec2 describe-snapshots --profile $profile --snapshot-ids $snapshot_id | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for Source snapshot creation to be completed"
done
done
