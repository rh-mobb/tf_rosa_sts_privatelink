#!/bin/bash

cd "$(dirname "$0")"

#provision all infrastructure 
cd rosa/
terraform apply -auto-approve

# extract cluster name
eval " $(terraform output --raw install_cluster)"
CLUSTER_NAME=$(terraform output --raw cluster_name)
echo "cluster name is $CLUSTER_NAME"

start_time="$(date -u +%s)"
# wait till cluster is ready
while [ $(rosa list cluster | grep $CLUSTER_NAME | awk '{ print $3 }')  != "ready" ]  
 do  
   echo "cluster $CLUSTER_NAME is $(rosa list cluster | grep $CLUSTER_NAME | awk '{ print $3 }')"
   now=$(date +"%T")
   echo "Current time  $now"
   sleep 5
   end_time="$(date -u +%s)"
   elapsed="$(($end_time-$start_time))"
   echo "Total of $elapsed min elapsed for process $(expr $elapsed / 60)"
   echo "Remaining time $(expr 40 - $(expr $elapsed / 60))"
done 

# associate hosted zone to egress VPC
ZONE=$(eval " $(terraform output --raw zone)")
echo "zone association $ZONE"
eval "$(terraform output --raw associate_route53_zone)"


# install OIDC 

echo "ready to install oauth"
cd ../oidc
# extract console uri
ROSA_CLUSTER_CONSOLE_URL=$(rosa describe cluster -c $CLUSTER_NAME | grep "Console URL" | awk '{ print $3 }')
#https://console-openshift-console.apps.mhs-2z.6mza.p1.openshiftapps.com

# create callback uri 
OAUTH_CALLBACK_URL=$(echo "$ROSA_CLUSTER_CONSOLE_URL" | sed "s/console-openshift-console/oauth-openshift/")/"oauth2callback/oidc"
#https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/Google
echo $OAUTH_CALLBACK_URL
#https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/GitHub

terraform apply -auto-approve -var="redirect_uris=$OAUTH_CALLBACK_URL" -var="post_logout_redirect_uris=$OAUTH_CALLBACK_URL"



