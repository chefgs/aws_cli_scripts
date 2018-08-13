sg_name=`aws ec2 describe-security-groups --filters Name=ip-permission.protocol,Values=tcp Name=ip-permission.to-port,Values=22 | grep -i "GroupName" | awk -F'\"' '{ print  $4 }' | xargs`
key_name=`aws ec2 describe-key-pairs | grep -i "KeyName" | awk -F'\"' '{ print  $4 }' | head -n 1`
echo "**SG name: $sg_name, Key name: $key_name**"
echo "Pass the above values to create_instance.sh script"