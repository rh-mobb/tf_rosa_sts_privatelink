

# provider "aws" {
#   # Configuration options
# }
# create a Random string
resource "random_string" "cluster_random_suffix" {
  length = 6
  upper = false
  special = false
}





#
# # Creating a New Key
resource "aws_key_pair" "bastion_key_pair" {

  # Name of the Key
  key_name   = "bastion_key_pair"

  # Adding the SSH authorized key !
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "${var.cluster_name}.bastion_key_pair.${random_string.cluster_random_suffix.id}"
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
  name = "bastion-host-sg"
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
    Name = "${var.cluster_name}.bastion_sg.${random_string.cluster_random_suffix.id}"
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
  
  # AMI ID [I have used my custom AMI which has some softwares pre installed]
  ami = "ami-0fa49cc9dc8d62c84"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.egress_vpc_pub_subnet.id

  # Keyname and security group are obtained from the reference of their instances created above!
  # Here I am providing the name of the key which is already uploaded on the AWS console.
  key_name = "bastion_key_pair"
  
  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${var.cluster_name}.bastion.${random_string.cluster_random_suffix.id}"
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


#### output 
output "bastion_ip_addr" {
  value = [ 
    aws_instance.bastion.private_ip,
    aws_instance.bastion.public_ip

  ] 
  description = "Bastion host private and public IP"
}

output "rosa_prv_subnet" {
  value = aws_subnet.rosa_prv_subnet.id
  description = "ROSA private subnet id"
}