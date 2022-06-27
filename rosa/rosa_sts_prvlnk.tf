module "rosa" {
   source = "../modules/rosa_sts_prvlnk/"

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