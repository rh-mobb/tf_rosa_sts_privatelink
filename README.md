# Using Terraform to build ROSA cluster with Private Link enabled and STS

Red Hat Openshift Service on AWS (ROSA) is a fully-managed turnkey application platform. A ROSA cluster can be created without any requirements on public subnets, internet gateways, or network address translation (NAT) gateways. In this configuration, Red Hat uses AWS PrivateLink to manage and monitor a cluster in order to avoid all public ingress network traffic.

To deploy Red Hat OpenShift Service on AWS (ROSA) into your existing Amazon Web Services (AWS) account, Red Hat requires several prerequisites to be met. There are several [requirements such as Customer requirements, Access requirements, Security requirements](https://docs.openshift.com/rosa/rosa_getting_started/rosa-sts-getting-started-workflow.html#rosa-sts-overview-of-the-deployment-workflow)


NOTE: STS(secure token service) allows us to deploy ROSA without needing a ROSA admin account, instead it uses roles and policies with Amazon STS to gain access to the AWS resources needed to install and operate the cluster.

In this series we use Terraform to provision all resources in AWS to deploy a ROSA cluster with Privatelink and STS.

## Create the AWS Virtual Private Cloud (VPCs), Pub/Private Subnets and TGW 

This terraform script provision 2 VPCs and 3 subnet as follows.

