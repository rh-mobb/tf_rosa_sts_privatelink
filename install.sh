#!/bin/bash
terraform apply -auto-approve

CLUSTER_NAME="mhs-2z"

while [ $(rosa list cluster | grep "$CLUSTER_NAME" | awk '{ print $3 }')  != "ready" ]  
 do  
   echo "cluster is not ready" 
   sleep 5 
done 

echo "ready to install oauth"


ROSA_CLUSTER_CONSOLE_URL=$(rosa describe cluster -c mhs-2z | grep "Console URL" | awk '{ print $3 }')
#https://console-openshift-console.apps.mhs-2z.6mza.p1.openshiftapps.com


OAUTH_CALLBACK_URL=$(echo "$ROSA_CLUSTER_CONSOLE_URL" | sed "s/console-openshift-console/oauth-openshift/")/"oauth2callback/oidc"
#https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/Google
echo $OAUTH_CALLBACK_URL
#https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/GitHub