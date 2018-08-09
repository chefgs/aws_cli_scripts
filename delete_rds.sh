###############################################################
## Script needs the below parameter
## param 1 - AWS account profile name - "default" or "account2"
## Example: 
## ./delete_rds.sh default
## ./delete_rds.sh 1 account2
##
## This script can be used to delete ALL the RDSs instances
## Script considers two AWS accounts 
## Those accounts configured with corresponding profile names "default" and "account2"
###############################################################

profile=$1
aws rds describe-db-instances --profile $profile | grep -iw "DBInstanceIdentifier" | awk -F'\"' '{ print  $4 }' | while read line
do
echo "Deleting rds name $line"
aws rds delete-db-instance --skip-final-snapshot --db-instance-identifier $line --profile $profile
done 
