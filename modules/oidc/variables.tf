
#####################
# OIDC VARRIABLES
####################


variable "base_url" {
  description = "The Okta base URL. Example: okta.com, oktapreview.com, etc. This is the domain part of your Okta org URL"
  default = "okta.com"
}
variable "org_name" {
  description = "The Okta org name. This is the part before the domain in your Okta org URL"
  default = "dev-40766750"
}

variable "api_token" {
  type        = string
  description = "The Okta API token, this will be read from environment variable (TF_VAR_api_token) for security"
  sensitive   = true
#  default = "00zg_t_1BbxE71A-Wah1eWknyAqT6KoNF521MpNsOm"
}

variable "redirect_uris" {
  type = string
  description = "callback uri"
  default = "https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/okta"
}

variable "post_logout_redirect_uris" {
  type = string
  description = "callback uri"
  default = "https://oauth-openshift.apps.mhs-2z.6mza.p1.openshiftapps.com/oauth2callback/okta"
}

variable "okta_admin_email" {
  type = string
  description = "okta admin email"
  default = "msarvest@redhat.com"
}

# Enable and configure the Okta provider
terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 3.15"
    }
  }
}

