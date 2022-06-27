data "template_file" "init" {
  template = "${file("${path.module}/templates/egress_proxy_user_data.sh")}"
  vars = {
    region = "${var.region}"
  }
}

resource "aws_key_pair" "egress-proxy-key-pair" {
  key_name   = "${local.name}-egress-proxy"
  public_key = file(var.bastion_key_loc)
  tags = {
    Name = "${local.name}-egress-proxy-key-pair"
  }
 }


resource "aws_instance" "egress_proxy" {
  ami =  var.proxy_ami
  instance_type = var.proxy_instance_type
  key_name = aws_key_pair.egress-proxy-key-pair.key_name
  user_data = data.template_file.init.rendered
  vpc_security_group_ids = [aws_security_group.egress-proxy_sg.id]
  subnet_id = aws_subnet.egress_vpc_pub_subnet.id

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
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "input for egress proxy"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

output "proxy_private_ip" {
    value = "${aws_instance.egress_proxy.private_ip}"
}
