profile=$1

aws s3api list-buckets --profile $profile | grep -i "name" | awk -F'\"' '{ print $4 }' | while read bucketname
do 
echo "Deleting bucket $bucketname"
aws s3api delete-bucket --bucket $bucketname --profile $profile
done
