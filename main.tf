# provider "aws" {
#   # Configuration options
# }
# create a Random string
resource "random_string" "cluster_random_suffix" {
  length = 2
  upper = false
  special = false
}

locals {
  name = "${var.cluster_name}-${random_string.cluster_random_suffix.id}"
}



# output "rosa_prv_subnet" {
#   value = aws_subnet.rosa_prv_subnet.id
#   description = "ROSA private subnet id"
# }

locals {
  multi_az = length(module.rosa-privatelink-vpc.rosa_subnet_ids) > 1 ? "--multi-az" : ""
}

output "next_steps" {
  value = <<EOF


***** Next steps *****

* Create your ROSA cluster:
$ rosa create cluster --cluster-name ${local.name} --mode auto --sts \
  --machine-cidr ${module.rosa-privatelink-vpc.rosa_vpc_cidr} --service-cidr 172.30.0.0/16 \
  --pod-cidr 10.128.0.0/14 --host-prefix 23 --yes \
  --private-link --subnet-ids ${join(",", module.rosa-privatelink-vpc.rosa_subnet_ids)} \
  ${local.multi_az}

* create a route53 zone association for the egress vpc
$ ZONE=$(aws route53 list-hosted-zones-by-vpc --vpc-id ${module.rosa-privatelink-vpc.rosa_vpc_id} \
    --vpc-region ${var.region} \
    --query 'HostedZoneSummaries[*].HostedZoneId' --output text)
  aws route53 associate-vpc-with-hosted-zone \
      --hosted-zone-id $ZONE \
      --vpc VPCId=${aws_vpc.egress_vpc.id},VPCRegion=${var.region} \
      --output text

* Create a sshuttle VPN via your bastion:
$ sshuttle --dns -NHr ec2-user@${aws_instance.bastion.public_ip} ${var.tgw_cidr_block}

* Create an Admin user:
$ rosa create admin -c ${local.name}

* Run the command provided above to log into the cluster

* Find the URL of the cluster's console and log into it via your web browser
$ rosa describe cluster -c mobb-infra -o json | jq -r .console.url


EOF
  description = "ROSA cluster creation command"
}
