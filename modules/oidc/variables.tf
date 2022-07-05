
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
  default = ""
  description = "The Okta API token, this will be read from environment variable (TF_VAR_api_token) for security"
  sensitive   = true

}

variable "oauth_app_name" {
  type = string
  description = "callback uri"
  default = "OCP_OKTA"
  
}

variable "redirect_uris" {
  type = string
  description = "callback uri"
  default = ""
  
}

variable "post_logout_redirect_uris" {
  type = string
  description = "callback uri"
  default = ""
}

variable "okta_admin_email" {
  type = string
  description = "okta admin email"
  default = "msarvest@redhat.com"
}

variable "cluster_admin_email" {
  type = string
  description = "ocp cluster admin email"
  default = "msarvest@redhat.com"
}

variable "dedicated_admin_email" {
  type = string
  description = "okta  dedicated admin email"
  default = "mohsen@redhat.com"
}

variable "restricted_user_email" {
  type = string
  description = "okta restricted user email"
  default = "houshym@gmail.com"
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

