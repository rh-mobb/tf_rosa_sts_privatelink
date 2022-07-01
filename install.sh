#!/bin/bash

cd "$(dirname "$0")"

#provision all infrastructure 
cd rosa/
terraform apply -auto-approve

# extract cluster name
eval " $(terraform output --raw install_cluster)"
CLUSTER_NAME=$(terraform output --raw cluster_name)
echo "cluster name is $CLUSTER_NAME"
BASTION_IP=$(terraform output --raw bastion_public_ip)
TGW_CIDR=$(terraform output --raw tgw_cidr)
start_time="$(date -u +%s)"
# wait till cluster is ready
while [ $(rosa list cluster | grep $CLUSTER_NAME | awk '{ print $3 }')  != "ready" ]  
 do  
   echo "cluster $CLUSTER_NAME is $(rosa list cluster | grep $CLUSTER_NAME | awk '{ print $3 }')"
   now=$(date +"%T")
#   echo "Current time  $now"
   sleep 30
   end_time="$(date -u +%s)"
   elapsed="$(($end_time-$start_time))"
#   echo "Total of $(expr $elapsed / 60) min elapsed  "
   echo "Approximate time remaining $(expr 40 - $(expr $elapsed / 60))"
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
ROSA_KUBE_API=$(rosa describe cluster -c $CLUSTER_NAME | grep "API URL" | awk '{ print $3 }')
# create callback uri 
OAUTH_CALLBACK_URL=$(echo "$ROSA_CLUSTER_CONSOLE_URL" | sed "s/console-openshift-console/oauth-openshift/")/"oauth2callback/okta"
#https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/Google
echo $OAUTH_CALLBACK_URL
#https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/GitHub



terraform apply -auto-approve -var="redirect_uris=$OAUTH_CALLBACK_URL" -var="post_logout_redirect_uris=$OAUTH_CALLBACK_URL"

CLIENT_ID=$(terraform output --raw client_id)
CLIENT_SECRET=$(terraform  output --raw client_secret)
ISSUER=$(terraform output --raw  issuer)

rosa create idp --cluster $CLUSTER_NAME --client-id $CLIENT_ID --client-secret $CLIENT_SECRET \
     --email-claims email --name-claims name --username-claims preferred_username,email \
     --issuer-url $ISSUER --type openid --name okta --extra-scopes email,profile



echo "waiting for oauth to be up and running approximatley 2 min  "
sleep 60

CLUSTER_ADMIN_EMAIL=$(terraform output --raw ocp_cluster_admin_email )
DEDICATED_ADMIN_EMAIL=$(terraform output --raw ocp_dedicated_admin_email)
rosa grant user cluster-admin -u $CLUSTER_ADMIN_EMAIL -c $CLUSTER_NAME 
rosa grant user dedicated-admin -u $DEDICATED_ADMIN_EMAIL -c $CLUSTER_NAME 


sshuttle --dns -NHr ec2-user@$BASTION_IP $TGW_CIDR