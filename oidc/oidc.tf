module "oidc" {
   source = "../modules/oidc/"
   api_token =  "00zg_t_1BbxE71A-Wah1eWknyAqT6KoNF521MpNsOm" 
   redirect_uris = "https://oauth-openshift.apps.mhs.ul4d.p1.openshiftapps.com/oauth2callback/oidc"
   post_logout_redirect_uris = "https://oauth-openshift.apps.mhs.ul4d.p1.openshiftapps.com/oauth2callback/oidc"
}

variable redirect_uris{
   default = ""
}


variable post_logout_redirect_uris{
   default = ""
}

output client_id {
   value = module.oidc.okta_app_oauth.ocp_oidc.client_id
}

output client_secret {
   value = module.oidc.okta_app_oauth.ocp_oidc.client_secret
}

