###############################################################
## Script needs the below 2 parameters
## param 1 - rds_count - count of 'n' number of RDS 
## param 2 - AWS account profile name - "default" or "account2"

## Example: 
## ./create_rds.sh 1 default
## ./create_rds.sh 1 account2

##
## This script can be used to create n number RDS instance of MySQL DB with encryption
## Script considers two AWS accounts 
## Those accounts configured with corresponding profile names "default" and "account2"
###############################################################

rds_count=$1
profile=$2

if [ $profile == 'account2' ] ; then
for ((i=1;i <= $rds_count;i+=1))
do ## Creating RDS $i in Account-2
echo "Creating RDS $i in $profile"
aws rds create-db-instance --db-instance-identifier mysql-db$RANDOM --allocated-storage 10 --db-instance-class db.t2.small --engine mysql --master-username myawsuser --master-user-password myawsuser --profile account2 --storage-encrypted 
done
else
for ((i=1;i <= $rds_count;i+=1))
do ## Creating RDS $i in Default account
echo "Creating RDS $i in $profile"
aws rds create-db-instance --db-instance-identifier mysql-db$RANDOM --allocated-storage 10 --db-instance-class db.t2.small --engine mysql --master-username myawsuser --master-user-password myawsuser --profile default --storage-encrypted
done
fi
