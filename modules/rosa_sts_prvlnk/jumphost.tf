
# create bastion key
resource "aws_key_pair" "jumphost" {
  count = var.enable_rosa_jumphost ? 1 : 0
  key_name   = "${local.name}-jumphost"
  public_key = file(var.bastion_key_loc)
  tags = {
    Name = "${local.name}-jumphost"
  }
 }

# create security group for bastion host
resource "aws_security_group" "jumphost" {
  count = var.enable_rosa_jumphost ? 1 : 0
  depends_on = [
    module.rosa-privatelink-vpc
  ]

  description = "jumphost in ROSA private subnet"
  name = "${local.name}-jumphost"
  vpc_id = module.rosa-privatelink-vpc.rosa_vpc_id
  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Bastion Host SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.tgw_cidr_block]
  }

  egress {
    description = "output from Bastion Host"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name}-jumphost"
  }

}

# Creating an AWS instance for the jumphost host
resource "aws_instance" "jumphost" {
  count = var.enable_rosa_jumphost ? 1 : 0
  depends_on = [
    module.rosa-privatelink-vpc,
    aws_security_group.jumphost
  ]
  ami = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id = module.rosa-privatelink-vpc.rosa_subnet_ids[0]
  key_name = aws_key_pair.jumphost[count.index].key_name

  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.jumphost[count.index].id]

  tags = {
    Name = "${local.name}-jumphost"
  }

  user_data = <<EOF
#!/bin/bash
set -e -x

sudo dnf install -y wget curl python36 python36-devel net-tools gcc libffi-devel openssl-devel jq bind-utils podman

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

mkdir openshift
tar -zxvf openshift-client-linux.tar.gz -C openshift
sudo install openshift/oc /usr/local/bin/oc
sudo install openshift/kubectl /usr/local/bin/kubectl
EOF

}


#### output
output "jumphost_ip_addr" {
  value = var.enable_rosa_jumphost ? aws_instance.jumphost[0].private_ip : null
  description = "Jumphost host private IP"
}
