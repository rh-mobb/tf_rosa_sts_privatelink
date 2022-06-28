module "oidc" {
   source = "../modules/oidc/"
   api_token =  "00zg_t_1BbxE71A-Wah1eWknyAqT6KoNF521MpNsOm" 
   redirect_uris = var.redirect_uris
   post_logout_redirect_uris = var.post_logout_redirect_uris
}

variable "redirect_uris" {
   default = ""
}


variable "post_logout_redirect_uris" {
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
   value= module.oidc.ocp_okta_issuer_url
}
