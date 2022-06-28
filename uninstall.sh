#!/bin/bash

cd "$(dirname "$0")"

#provision all infrastructure 
cd rosa/
CLUSTER_NAME=$(terraform output --raw cluster_name)
echo "cluster name is $CLUSTER_NAME"
rosa delete cluster -c $CLUSTER_NAME -y


while [ "$(rosa list cluster | grep $CLUSTER_NAME | awk '{ print $3 }')"  != "" ]  
 do  
   echo "cluster status is $(rosa list cluster | grep $CLUSTER_NAME | awk '{ print $3 }')"
   echo "cluster is not deleted" 
   sleep 5 
done 

# destroy infrastructure
terraform destroy -auto-approve



# install OIDC 

echo "ready to install oauth"
cd ../oidc


terraform destroy -auto-approve
