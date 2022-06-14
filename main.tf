# provider "aws" {
#   # Configuration options
# }
# create a Random string
# resource "random_string" "cluster_random_suffix" {
#   length = 6
#   upper = false
#   special = false
# }

locals {
  name = "rosa-${var.cluster_name}"
}


# create bastion key
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = local.name
  public_key = file(var.bastion_key_loc)
  tags = {
    Name = local.name
  }
 }

# create security group for bastion host
resource "aws_security_group" "bastion_sg" {

  depends_on = [
    aws_vpc.egress_vpc,
    aws_subnet.egress_vpc_pub_subnet,
    aws_subnet.egress_vpc_prv_subnet
  ]

  description = "to access to ROSA cluster"
  name = local.name
  vpc_id = aws_vpc.egress_vpc.id

  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Bastion Host SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from Bastion Host"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.name
  }

}

# Creating an AWS instance for the batsion host
resource "aws_instance" "bastion" {
  depends_on = [
    aws_vpc.egress_vpc,
    aws_subnet.egress_vpc_pub_subnet,
    aws_subnet.egress_vpc_prv_subnet,
    aws_security_group.bastion_sg,
  ]
  ami = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id = aws_subnet.egress_vpc_pub_subnet.id
  key_name = aws_key_pair.bastion_key_pair.key_name

  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = local.name
  }

  user_data = <<EOF
#!/bin/bash
set -e -x

sudo dnf install -y wget curl python36 python36-devel net-tools gcc libffi-devel openssl-devel jq bind-utils podman

# mitmproxy

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

mkdir openshift
tar -zxvf openshift-client-linux.tar.gz -C openshift
sudo install openshift/oc /usr/local/bin/oc
sudo install openshift/kubectl /usr/local/bin/kubectl
EOF

}


#### output
# output "bastion_ip_addr" {
#   value = [
#     aws_instance.bastion.private_ip,
#     aws_instance.bastion.public_ip

#   ]
#   description = "Bastion host private and public IP"
# }

# output "rosa_prv_subnet" {
#   value = aws_subnet.rosa_prv_subnet.id
#   description = "ROSA private subnet id"
# }

output "next_steps" {
  value = <<EOF


***** Next steps *****

* Create your ROSA cluster:
$ rosa create cluster --cluster-name ${local.name} --mode auto --sts \
  --machine-cidr ${var.rosa_subnet_cidr_block} --service-cidr 172.30.0.0/16 \
  --pod-cidr 10.128.0.0/14 --host-prefix 23 --yes \
  --private-link --subnet-ids ${aws_subnet.rosa_prv_subnet.id}

* create a route53 zone association for the egress vpc
$ ZONE=$(aws route53 list-hosted-zones-by-vpc --vpc-id ${aws_vpc.rosa_prvlnk_vpc.id} \
    --vpc-region ${var.region} \
    --query 'HostedZoneSummaries[*].HostedZoneId' --output text)
  aws route53 associate-vpc-with-hosted-zone \
      --hosted-zone-id $ZONE \
      --vpc VPCId=${aws_vpc.egress_vpc.id},VPCRegion=${var.region} \
      --output text

* Create a sshuttle VPN via your bastion:
$ sshuttle --dns -NHr ec2-user@${aws_instance.bastion.public_ip} 10.0.0.0/8

* Create an Admin user:
$ rosa create admin -c ${local.name}

* Run the command provided above to log into the cluster

* Find the URL of the cluster's console and log into it via your web browser
$ rosa describe cluster -c mobb-infra -o json | jq -r .console.url


EOF
  description = "ROSA cluster creation command"
}
