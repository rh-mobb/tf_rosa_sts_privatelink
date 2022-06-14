# create egress vpc for bastion host/ application publishing

resource "aws_vpc" "egress_vpc" {
  cidr_block       = var.egress_vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${local.name}-egress"
  }
}
resource "aws_subnet" "egress_vpc_prv_subnet" {
  vpc_id     = aws_vpc.egress_vpc.id
  cidr_block = var.egress_prv_subnet_cidr_block
  availability_zone = "us-east-2a"
  tags = {
    Name = "${local.name}-egress"
  }
}
resource "aws_subnet" "egress_vpc_pub_subnet" {
  vpc_id     = aws_vpc.egress_vpc.id
  cidr_block = var.egress_pub_subnet_cidr_block
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-egress"
  }
}

resource "aws_internet_gateway" "egress_vpc_gw" {
  vpc_id = aws_vpc.egress_vpc.id

  tags = {
    Name = "${local.name}-egress"
  }
}

resource "aws_eip" "nat_gateway_eip" {
#   depends_on = [
#     aws_route_table_association.RT-IG-Association
#   ]
  vpc = true
}

resource "aws_nat_gateway" "egress_vpc_nat" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.egress_vpc_pub_subnet.id

  tags = {
    Name = "${local.name}-egress"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.egress_vpc_gw]
}

resource "aws_route_table" "egress_vpc_pub_rt" {
  vpc_id = aws_vpc.egress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.egress_vpc_gw.id
  }
  route {
    cidr_block = var.rosa_subnet_cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  }
   depends_on = [
       aws_ec2_transit_gateway.rosa_transit_gateway
   ]

  tags = {
    Name = "${local.name}-egress"
  }
}

resource "aws_route_table_association" "egress_vpc_pub_rt_association" {
  subnet_id      = aws_subnet.egress_vpc_pub_subnet.id
  route_table_id = aws_route_table.egress_vpc_pub_rt.id
}

resource "aws_route_table" "egress_vpc_prv_rt" {
  vpc_id = aws_vpc.egress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.egress_vpc_nat.id
  }
  route {
    cidr_block = var.rosa_subnet_cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
  }
  depends_on = [
       aws_ec2_transit_gateway.rosa_transit_gateway
  ]

  tags = {
    Name = "${local.name}-egress"
  }
}

resource "aws_route_table_association" "egress_vpc_prv_rt_association" {
  subnet_id      = aws_subnet.egress_vpc_prv_subnet.id
  route_table_id = aws_route_table.egress_vpc_prv_rt.id
}
