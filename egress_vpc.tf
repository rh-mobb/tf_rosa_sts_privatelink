# create egress vpc for bastion host/ application publishing

resource "aws_vpc" "egress_vpc" {
  cidr_block       = var.egress_vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${local.name}-egress-vpc"
  }
}
resource "aws_subnet" "egress_vpc_prv_subnet" {
  vpc_id     = aws_vpc.egress_vpc.id
  cidr_block = var.egress_prv_subnet_cidr_block
  availability_zone = "us-east-2a"
  tags = {
    Name = "${local.name}-egress-prv-subnet"
  }
}
resource "aws_subnet" "egress_vpc_pub_subnet" {
  vpc_id     = aws_vpc.egress_vpc.id
  cidr_block = var.egress_pub_subnet_cidr_block
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-egress-pub-subnet"
  }
}

resource "aws_internet_gateway" "egress_vpc_gw" {
  vpc_id = aws_vpc.egress_vpc.id

  tags = {
    Name = "${local.name}-egress-vpc-gw"
  }
}

# resource "aws_eip" "nat_gateway_eip" {
# #   depends_on = [
# #     aws_route_table_association.RT-IG-Association
# #   ]
#   vpc = true
# }

# resource "aws_nat_gateway" "egress_vpc_nat" {
#   allocation_id = aws_eip.nat_gateway_eip.id
#   subnet_id     = aws_subnet.egress_vpc_pub_subnet.id

#   tags = {
#     Name = "${local.name}-egress"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.egress_vpc_gw]
# }

resource "aws_route_table" "egress_vpc_pub_rt" {
  vpc_id = aws_vpc.egress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.egress_vpc_gw.id
  }
  route {
    cidr_block = var.tgw_cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  }
   depends_on = [
       aws_ec2_transit_gateway.rosa_transit_gateway
   ]

  tags = {
    Name = "${local.name}-egress-vpc-pub-rt"
  }
}

resource "aws_route_table_association" "egress_vpc_pub_rt_association" {
  subnet_id      = aws_subnet.egress_vpc_pub_subnet.id
  route_table_id = aws_route_table.egress_vpc_pub_rt.id
}

resource "aws_route_table" "egress_vpc_prv_rt" {
  vpc_id = aws_vpc.egress_vpc.id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   network_interface_id = aws_network_interface.egress_proxy_interface.id
  # }
  route {
    cidr_block = var.tgw_cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  }
  depends_on = [
       aws_ec2_transit_gateway.rosa_transit_gateway
  ]

  tags = {
    Name = "${local.name}-egress-vpc-prv-rt"
  }
}

resource "aws_route_table_association" "egress_vpc_prv_rt_association" {
  subnet_id      = aws_subnet.egress_vpc_prv_subnet.id
  route_table_id = aws_route_table.egress_vpc_prv_rt.id
}

# attach tgw to vpc (it is mandatory before you update subnet route table in the vpc)
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_egress_vpc" {
  subnet_ids         = [
      aws_subnet.egress_vpc_prv_subnet.id,
#      aws_subnet.egress_vpc_prv_subnet.id
  ]
  transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  vpc_id             = aws_vpc.egress_vpc.id
  tags = {
    Name = "${var.cluster_name}-tgw-attach-egress-vpc"
  }
}

# resource "aws_ec2_transit_gateway_route" "tgw_egress_route" {
#   destination_cidr_block         = "10.2.0.0/16"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_egress_vpc.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
# }
