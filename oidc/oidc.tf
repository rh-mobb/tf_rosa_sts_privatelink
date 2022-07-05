module "oidc" {
   source = "../modules/oidc/"
   api_token =  "" 
   redirect_uris = var.redirect_uris
   post_logout_redirect_uris = var.post_logout_redirect_uris
   org_name = "dev-40766750"
   base_url = "okta.com"
   okta_admin_email = "msarvest@redhat.com"
   cluster_admin_email = "msarvest@redhat.com"
   dedicated_admin_email = "mohsen@redhat.com"
   restricted_user_email = "houshym@gmail.com"
   oauth_app_name = "OCP_OKTA1"  # check for duplication in OKTA account
}

variable "api_token" {
  type        = string
  default = ""
  description = "The Okta API token, this will be read from environment variable (TF_VAR_api_token) for security"
  sensitive   = true

}

variable "redirect_uris" {
   default = ""
}


variable "post_logout_redirect_uris" {
   default = ""
}

variable "cluster_admin_email" {
   default = ""
}

variable "dedicated_admin_email" {
   default = ""
}

variable "restricted_user_email" {
   default = ""
}


output client_id {
   value = module.oidc.client_id
}

output client_secret {
   value = module.oidc.client_secret
   sensitive = true
}

output issuer {
   value = module.oidc.ocp_okta_issuer_url
}

output ocp_cluster_admin_email {
   value = module.oidc.cluster_admin_email 
}

output ocp_dedicated_admin_email {
    value = module.oidc.dedicated_admin_email
 }

output ocp_restricted_user_email {
    value = module.oidc.restricted_user_email
 }