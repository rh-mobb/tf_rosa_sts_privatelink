# create transit gateway(tgw)
resource "aws_ec2_transit_gateway" "rosa_transit_gateway" {
  description = "transit gateway to connect private subnet to internet"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support = "enable"
  vpn_ecmp_support = "enable"
  tags = {
    Name = "${var.cluster_name}-tgw"
  }
}

output "tgw_cidr" {
   value= var.tgw_cidr_block
}

# # attach tgw to vpc (it is mandatory before you update subnet route table)
# resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_rosa_vpc" {
#   subnet_ids         = [aws_subnet.rosa_prv_subnet.id]
#   transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
#   vpc_id             = aws_vpc.rosa_prvlnk_vpc.id
#   depends_on = [
#     aws_vpc.rosa_prvlnk_vpc
#   ]
#   tags = {
#     Name = "${var.cluster_name}-tgw"
#   }
# }


# resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
#   transit_gateway_id = aws_ec2_transit_gateway.rosa_transit_gateway.id
#   tags = {
#     Name = "${var.cluster_name}.tgw_route_table.${random_string.cluster_random_suffix.id}"
#   }
# }

### add route to tgw route table

# resource "aws_ec2_transit_gateway_route" "tgw_static_route" {
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_egress_vpc.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.rosa_transit_gateway.association_default_route_table_id
# }

# resource "aws_ec2_transit_gateway_route" "tgw_rosa_route" {
#   destination_cidr_block         = "10.1.0.0/16"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_rosa_vpc.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id

# }

# resource "aws_ec2_transit_gateway_route" "tgw_egress_route" {
#   destination_cidr_block         = "10.2.0.0/16"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_egress_vpc.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id

# }



# resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_rosa_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_rosa_vpc.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id

# }

# resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_egress_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_egress_vpc.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id

# }
