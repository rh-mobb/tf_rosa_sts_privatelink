resource "aws_network_interface" "proxy_interface" {
    subnet_id = aws_subnet.egress_vpc_pub_subnet.id

    # Important to disable this check to allow traffic not addressed to the
    # proxy to be received
    source_dest_check = false
}

resource "aws_instance" "egress_proxy" {
    ami =  var.bastion_ami
    instance_type = var.bastion_instance_type
    key_name = aws_key_pair.bastion_key_pair.key_name

    user_data = "${file("egress_proxy_user_data.sh")}"

    network_interface {
        network_interface_id = "${aws_network_interface.proxy_interface.id}"
        device_index = 0
    }

    tags = {
        Name = "egress_proxy"
    }
}

# Outputs
output "proxy_public_ip" {
    value = "${aws_instance.egress_proxy.public_ip}"
}

output "proxy_network_interface_id" {
    value = "${aws_network_interface.proxy_interface.id}"
}