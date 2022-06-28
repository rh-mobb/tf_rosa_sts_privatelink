
# create bastion key
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = local.name
  public_key = file(var.bastion_key_loc)
  tags = {
    Name = "${local.name}_bastion_key_pair"
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
    Name = "${local.name}_bastion_sg"
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
    Name = "${local.name}-bastion"
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

output "bastion_ip_addr" {
  value = [
    aws_instance.bastion.private_ip,
    aws_instance.bastion.public_ip

  ]
  description = "Bastion host private and public IP"
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip

  description = "Bastion public IP"
}