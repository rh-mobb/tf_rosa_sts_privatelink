module "rosa" {
   source = "../modules/rosa_sts_prvlnk/"
   cluster_name = "rosa-tf-idp"
   enable_rosa_jumphost = false

}


output "install_cluster" {
    value = module.rosa.install_cluster
}

output "cluster_name" {
   value = module.rosa.cluster_name
}

output "zone" {
   value = module.rosa.zone
}

output "associate_route53_zone" {
   value = module.rosa.associate_route53_zone
}

output "bastion_public_ip" {
   value = module.rosa.bastion_public_ip
}

output "tgw_cidr" {
   value = module.rosa.tgw_cidr
} 