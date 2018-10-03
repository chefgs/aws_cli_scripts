#############################################################
# Script notes #
# Script takes the instance_id as input argument
# AWS EC2 root volumes created out of pre-defined AMIs, usually not encrypted by default.
# But as part of disc security we have to encrypt the root volumes too.
# Disc volume encryption could be done at 2 different level.
# 1. Encrypt - After creating the EC2 instance, 2. Encrypt - Before Creating EC2 instances 
#
# The script below can be used for level 1. where EC2 instance created with un-encrypted root volume
# As part of script, we will be encrypting the root volume
# 
# The script has 2 parts. Let me brief you what they are.
# Part 1 section:
# 1. Stop the running instance
# 2. Get the un-encrypted volume-id and Create snapshot of the un-encrypted root volume
# 3. Copy the snapshot and encrypt it
# Part 2 section:
# 4. Create new volume from the encrypted snapshot
# 5. Detach existing un-encrypted root volume
# 6. Attach new encrypted volume created in step 4
# 7. Start the instance
#
# If anyone wants to do level 2: i.e, Encrypt - Before Creating EC2 instances
# Basically, there is a "one time" step involved for creating a NEW AMI using the encrypted snapshot.
# Follow the steps below,
# 1. Perform Part 1 section (upto creation of encrypted snapshot) of script
# 2. Create AMI using the encrypted snapshot of root volume
# 3. Newly created AMI will be available under MyAMI when launching the instance
# 4. Create EC2 instance using the new AMI 
# 5. We can see the root volume of instance is NOW encrypted by default
#############################################################
instance_id=$1 

######### Part 1 section - starts here ##############
# Stop instances
echo "Stop instance"
aws ec2 stop-instances --instance-ids $instance_id

while [ "$instance_state" != "stopped" ]
do
instance_state=`aws ec2 describe-instances --instance-ids $instance_id | grep -A 3 "State" | grep -i "Name" | awk -F'\"' '{ print  $4 }'`
echo "Waiting to instance state changed to STOPPED"
done

echo "Get Volume ID not encrypted"
volume=`aws ec2 describe-instances --filters "Name=instance-id,Values=$instance_id" | grep -A 6 "sda1" | grep -i "VolumeID" | awk -F'\"' '{ print  $4 }'`
echo $volume

echo "Create snapshot of Volume"
snapshot_id=`aws ec2 create-snapshot --volume-id $volume | grep -i "SnapshotId" | awk -F'\"' '{ print $4 }'`
echo $snapshot_id

while [ "$snapshot1_status" != "completed" ]
do
snapshot1_status=`aws ec2 describe-snapshots --snapshot-ids $snapshot_id | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for Source snapshot creation to be completed"
done

echo "Copy the snapshot and encrypt it"
copied_snapshot=`aws --region us-west-2 ec2 copy-snapshot --source-region us-west-2 --source-snapshot-id $snapshot_id --encrypted  | grep -i "SnapshotId" | awk -F'\"' '{ print  $4 }'`
echo $copied_snapshot

while [ "$snapshot2_status" != "completed" ]
do
snapshot2_status=`aws ec2 describe-snapshots --snapshot-ids $copied_snapshot | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting form copied snapshot creation to be completed"
done
######### Part 1 section - ends here ##############

######### Part 2 section - starts here ##############
echo "Create new volume from encrypted snapshot"
new_encrypt_volume=`aws ec2 create-volume --size 10 --region us-west-2 --availability-zone us-west-2b --volume-type gp2 --snapshot-id $copied_snapshot | grep -i "VolumeID" | awk -F'\"' '{ print  $4 }'`
echo $new_encrypt_volume

while [ "$new_volume_state" != "available" ]
do
new_volume_state=`aws ec2 describe-volumes --volume-ids $new_encrypt_volume | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for new volume creation to be completed"
done

echo "Detach un-encrypted volume"
aws ec2 detach-volume --volume-id $volume

while [ "$old_volume_state" != "available" ]
do
old_volume_state=`aws ec2 describe-volumes --volume-ids $volume | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for new volume creation to be completed"
done

echo "Attach newly encrypted volume"
aws ec2 attach-volume --volume-id $new_encrypt_volume --instance-id $instance_id --device /dev/sda1

while [ "$new_volume_state" != "in-use" ]
do
old_volume_state=`aws ec2 describe-volumes --volume-ids $new_encrypt_volume | grep -i "State" | awk -F'\"' '{ print  $4 }'`
echo "Waiting for attaching new volume to be completed"
done

echo " Start instances"
aws ec2 start-instances --instance-ids $instance_id
######### Part 2 section - ends here ##############