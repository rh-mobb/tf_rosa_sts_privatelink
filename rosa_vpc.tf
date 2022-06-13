# create a private vpc for rosa cluster
resource "aws_vpc" "rosa_prvlnk_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.cluster_name}.rosa_prvlnk_vpc.${random_string.cluster_random_suffix.id}"
  }
}
# create private subnet
resource "aws_subnet" "rosa_prv_subnet" {
  vpc_id     = aws_vpc.rosa_prvlnk_vpc.id
  cidr_block = var.rosa_subnet_cidr_block
  availability_zone = "us-east-2a"
  depends_on = [
    aws_vpc.rosa_prvlnk_vpc
  ]


  tags = {
    Name = "${var.cluster_name}.rosa_prv_subnet.${random_string.cluster_random_suffix.id}"
  }
}



resource "aws_route_table" "rosa_prvlnk_vpc_rt" {
  vpc_id = aws_vpc.rosa_prvlnk_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  }
  route {
    cidr_block = var.egress_vpc_cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  }
  depends_on = [ 
      aws_ec2_transit_gateway.rosa_transit_gateway
  ]
   
  tags = {
    Name = "${var.cluster_name}.rosa_prv_subnet_rt.${random_string.cluster_random_suffix.id}"
  }
}

resource "aws_route_table_association" "prv_rt_association" {
  subnet_id      = aws_subnet.rosa_prv_subnet.id
  route_table_id = aws_route_table.rosa_prvlnk_vpc_rt.id
  depends_on = [

  ]
}

resource "aws_instance" "spoke_vm" {

  depends_on = [
    aws_vpc.rosa_prvlnk_vpc,
    aws_subnet.rosa_prv_subnet,
  ]
  
  # AMI ID [I have used my custom AMI which has some softwares pre installed]
  ami = "ami-0fa49cc9dc8d62c84"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.rosa_prv_subnet.id

  # Keyname and security group are obtained from the reference of their instances created above!
  # Here I am providing the name of the key which is already uploaded on the AWS console.
  key_name = "bastion_key_pair"
  
  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.spoke_sg.id]

  tags = {
    Name = "${var.cluster_name}.spoke_vm.${random_string.cluster_random_suffix.id}"
  }

  # Installing required softwares into the system!
#   connection {
#     type = "ssh"
#     user = "ec2-user"
#     private_key = file("/Users/mhs/.ssh")
#     host = aws_instance.webserver.public_ip
#   }

  # Code for installing the softwares!
#   provisioner "remote-exec" {
#     inline = [
#         "sudo yum update -y",
#         "sudo yum install php php-mysqlnd httpd -y",
#         "wget https://wordpress.org/wordpress-4.8.14.tar.gz",
#         "tar -xzf wordpress-4.8.14.tar.gz",
#         "sudo cp -r wordpress /var/www/html/",
#         "sudo chown -R apache.apache /var/www/html/",
#         "sudo systemctl start httpd",
#         "sudo systemctl enable httpd",
#         "sudo systemctl restart httpd"
#     ]
#   }
}

resource "aws_security_group" "spoke_sg" {

  depends_on = [
    aws_vpc.rosa_prvlnk_vpc,
    aws_subnet.rosa_prv_subnet
  ]

  description = "to access to ROSA cluster"
  name = "spoke-host-sg"
  vpc_id = aws_vpc.rosa_prvlnk_vpc.id

  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Spoke Host SG"
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
    Name = "${var.cluster_name}.spoke_sg.${random_string.cluster_random_suffix.id}"
  }
}