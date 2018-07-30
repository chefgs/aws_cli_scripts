###############################################################
## Script needs the below parameter
## param 1 - AWS account profile name - "default" or "account2"

## Example: 
## ./delete_v2_elb.sh 1 default
## ./delete_v2_elb.sh 1 account2

##
## This script can be used to delete ALL the ELBs of type V2
## Script considers two AWS accounts 
## Those accounts configured with corresponding profile names "default" and "account2"
###############################################################

prof=$1
aws elbv2 describe-load-balancers  --profile $prof | grep -i "arn" | awk -F'\"' '{ print  $4 }' | while read line
do
echo "Deleting elbv2 name $line"
aws elbv2 delete-load-balancer --load-balancer-arn $line --profile $prof
done 
