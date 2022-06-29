#!/bin/bash

cd "$(dirname "$0")"

#provision all infrastructure 
cd rosa/

# extract cluster name

CLUSTER_NAME=$(terraform output --raw cluster_name)
echo "cluster name is $CLUSTER_NAME"
BASTION_IP=$(terraform output --raw bastion_public_ip)
echo "Bastion IP to connect $BASTION_IP"
TGW_CIDR=$(terraform output --raw tgw_cidr)
echo "Transit gateway CIDR $TGW_CIDR"
ROSA_CLUSTER_CONSOLE_URL=$(rosa describe cluster -c $CLUSTER_NAME | grep "Console URL" | awk '{ print $3 }')
echo "open browser and hit $ROSA_CLUSTER_CONSOLE_URL"
ROSA_KUBE_API=$(rosa describe cluster -c $CLUSTER_NAME | grep "API URL" | awk '{ print $3 }')
echo "cluster API $ROSA_KUBE_API"


sshuttle --dns -NHr ec2-user@$BASTION_IP $TGW_CIDR