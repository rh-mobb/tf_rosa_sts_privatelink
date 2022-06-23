resource "aws_key_pair" "egress-proxy-key-pair" {
  key_name   = "${local.name}-egress-proxy"
  public_key = file(var.bastion_key_loc)
  tags = {
    Name = "${local.name}-egress-proxy-key-pair"
  }
 }


resource "aws_network_interface" "egress_proxy_interface" {
    subnet_id = aws_subnet.egress_vpc_pub_subnet.id
    security_groups = [aws_security_group.egress-proxy_sg.id]
    # Important to disable this check to allow traffic not addressed to the
    # proxy to be received
    source_dest_check = false
    tags = {
        Name = "${local.name}_egress_proxy_interface"
    }
}

resource "aws_instance" "egress_proxy" {
    ami =  var.bastion_ami
    instance_type = var.bastion_instance_type
    key_name = aws_key_pair.egress-proxy-key-pair.key_name
    user_data = "${file("egress_proxy_user_data.sh")}"
    network_interface {
        network_interface_id = "${aws_network_interface.egress_proxy_interface.id}"
        device_index = 0
    }
# Security groups to use! 
# if you define the network_interface block then  you're overriding the default ENI and so can't
# specify security groups at the instance level
#   vpc_security_group_ids = [aws_security_group.egress-proxy_sg.id]

    tags = {
        Name = "${local.name}_egress_proxy"
    }
}

# create security group for egress proxy
resource "aws_security_group" "egress-proxy_sg" {

  description = "egress proxy"
  name = "${local.name}-egress-proxy"
  vpc_id = aws_vpc.egress_vpc.id
  # Created an inbound rule for egress proxy SSH
  ingress {
    description = "input for egress proxy"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from egress proxy"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name}-egress-proxy"
  }

}


# Outputs
output "proxy_public_ip" {
    value = "${aws_instance.egress_proxy.public_ip}"
}

output "proxy_network_interface_id" {
    value = "${aws_network_interface.egress_proxy_interface.id}"
}