#####################################################
## Script needs the below 3 parameters
## param 1 - elb_type - "classic" or "v2"
## param 2 - elb_count - numerical value of count n
## param 3 - AWS account - "default" or "account2"

## Example: 
## ./create_n_elbs.sh classic 1 default
## ./create_n_elbs.sh v2 1 default
##
## ./create_n_elbs.sh v2 1 account2
## ./create_n_elbs.sh classic 1 account2

## This script creates n number of ELBs of type Classic or V2 
#####################################################

elb_type=$1
elb_count=$2
profile=$3

case $elb_type in
"classic")
if [ $profile == 'account2' ] ; then
for ((i=1;i <= $elb_count;i+=1))
do ## Creating Classic ELB $i in Account-2
echo "Creating $elb_type ELB $i in $profile"
aws elb create-load-balancer --load-balancer-name awsacct2-$i-elb$RANDOM --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones us-west-2a us-west-2b --profile account2
done
else
for ((i=1;i <= $elb_count;i+=1))
do ## Creating Classic ELB $i in Default account
echo "Creating $elb_type ELB $i in $profile"
aws elb create-load-balancer --load-balancer-name awsacct1-$i-elb$RANDOM --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones us-west-2a us-west-2b --profile default
done
fi;;
"v2")
if [ $profile == 'account2' ] ; then
for ((i=1;i <= $elb_count;i+=1))
do ## Creating V2 ELB $i in Account-2
echo "Creating $elb_type ELB $i in $profile"
aws elbv2 create-load-balancer --name awsacct2-$i-elb$RANDOM --subnets subnet-854db3e3 subnet-b8adbdf1 --profile account2
done
else
for ((i=1;i <= $elb_count;i+=1))
do ## Creating V2 ELB $i in Default account
echo "Creating $elb_type ELB $i in $profile"
aws elbv2 create-load-balancer --name awsacct1-elb$RANDOM --subnets subnet-a4a9bcfc subnet-e545f5ac --profile default
done
fi;; 
*) echo "NO ELB Type was mentioned"
esac
