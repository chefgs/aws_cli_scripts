profile=$1

aws rds describe-db-instances --profile $profile | grep -iw "DBInstanceIdentifier" | awk -F'\"' '{ print  $4 }' > rds_in_$profile.txt 
