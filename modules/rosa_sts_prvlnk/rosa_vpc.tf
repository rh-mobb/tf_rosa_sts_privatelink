# # create a private vpc for rosa cluster

module "rosa-privatelink-vpc" {
  source  = "rh-mobb/rosa-privatelink-vpc/aws"
  version = "0.0.2"
  name = "${local.name}"
  region = var.region
  azs  = var.availability_zones
  cidr = var.rosa_vpc_cidr_block
  private_subnets_cidrs = var.rosa_subnet_cidr_blocks
  transit_gateway = {
    peer = true
    transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
    dest_cidrs = ["0.0.0.0/0"]
  }
}


# resource "aws_vpc" "rosa_prvlnk_vpc" {
#   cidr_block       = var.vpc_cidr_block
#   instance_tenancy = "default"
#   enable_dns_hostnames = true
#   enable_dns_support = true
#   tags = {
#     Name = "${local.name}-rosa"
#   }
# }
# # create private subnet
# resource "aws_subnet" "rosa_prv_subnet" {
#   vpc_id     = aws_vpc.rosa_prvlnk_vpc.id
#   cidr_block = var.rosa_subnet_cidr_block
#   availability_zone = "us-east-2a"
#   depends_on = [
#     aws_vpc.rosa_prvlnk_vpc
#   ]
#   lifecycle {
#     ignore_changes = [tags]
#   }

#   tags = {
#     Name = "${local.name}-rosa"
#   }
# }

# resource "aws_route_table" "rosa_prvlnk_vpc_rt" {
#   vpc_id = aws_vpc.rosa_prvlnk_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
#   }
#   route {
#     cidr_block = var.egress_vpc_cidr_block
#     transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
#   }
#   depends_on = [
#       aws_ec2_transit_gateway.rosa_transit_gateway
#   ]

#   tags = {
#     Name = "${local.name}-rosa"
#   }
# }

# resource "aws_route_table_association" "prv_rt_association" {
#   subnet_id      = aws_subnet.rosa_prv_subnet.id
#   route_table_id = aws_route_table.rosa_prvlnk_vpc_rt.id
#   depends_on = [

#   ]
# }
