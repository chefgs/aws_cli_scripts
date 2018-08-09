###############################################################
## Script needs the below parameter
## param 1 - AWS account profile name - "default" or "account2"

## Example: 
## ./delete_classic_elb.sh default
## ./delete_classic_elb.sh account2

##
## This script can be used to delete ALL the ELBs of type Classic
## Script considers two AWS accounts 
## Those accounts configured with corresponding profile names "default" and "account2"
###############################################################

prof=$1
aws elb describe-load-balancers  --profile $prof | grep -i "LoadBalancerName" | awk -F'\"' '{ print  $4 }' | while read line
do
echo "Deleting elb name $line"
aws elb delete-load-balancer --load-balancer-name $line --profile $prof
done 
