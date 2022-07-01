
provider "okta" {
  org_name  = var.org_name
  base_url  = var.base_url
  api_token = var.api_token
}



# Set up OKTA groups
resource "okta_group" "ocp_admin" {
  name        = "ocp-admins"
  description = "Users who can access openshift cluster as admins"
}

resource "okta_group" "ocp_restricted_users" {
  name        = "ocp-restricted-users"
  description = "Users who can only view pods and services in default namespace"
}



# Assign users to the groups
data "okta_user" "admin" {
  search {
    name  = "profile.email"
    value = "${var.okta_admin_email}"
  }
}

resource "okta_group_memberships" "admin_user" {
  group_id = okta_group.ocp_admin.id
  users = [
    data.okta_user.admin.id
  ]
}

data "okta_user" "restricted_user" {
  search {
    name  = "profile.email"
    value = "${var.restricted_user_email}"
  }
}

resource "okta_group_memberships" "restricted_user" {
  group_id = okta_group.ocp_restricted_users.id
  users = [
    data.okta_user.restricted_user.id
  ]
}


# Create an OIDC application

resource "okta_app_oauth" "ocp_okta" {
  label                      = var.oauth_app_name
  type                       = "web" # this is important
#  token_endpoint_auth_method = "none"   # this sets the client authentication to PKCE
  consent_method = "REQUIRED"
  grant_types = [
    "authorization_code"
  ]
  response_types = ["code"]
  redirect_uris = [
    var.redirect_uris
  ]
  post_logout_redirect_uris = [
    var.post_logout_redirect_uris
  ]
  lifecycle {
    ignore_changes = [groups]
  }
}

# Assign groups to the OIDC application
resource "okta_app_group_assignments" "ocp_okta_group" {
  app_id = okta_app_oauth.ocp_okta.id
  group {
    id = okta_group.ocp_admin.id
  }
  group {
    id = okta_group.ocp_restricted_users.id
  }
}

output "ocp_okta_client_id" {
  value = okta_app_oauth.ocp_okta.client_id
}

output "ocp_okta_client_secret" {
  value = okta_app_oauth.ocp_okta.client_secret
  sensitive = true
}




# Create an authorization server

resource "okta_auth_server" "oidc_auth_server" {
  name      = "ocp-auth"
  audiences = ["http:://localhost:8000"]
}

output "ocp_okta_issuer_url" {
  value = okta_auth_server.oidc_auth_server.issuer
}


output client_id {
   value = okta_app_oauth.ocp_okta.client_id
}

output client_secret {
   value = okta_app_oauth.ocp_okta.client_secret
   sensitive = true
}




# Add claims to the authorization server

resource "okta_auth_server_claim" "auth_claim" {
  name                    = "groups"
  auth_server_id          = okta_auth_server.oidc_auth_server.id
  always_include_in_token = true
  claim_type              = "IDENTITY"
  group_filter_type       = "STARTS_WITH"
  value                   = "ocp-"
  value_type              = "GROUPS"
}

resource "okta_auth_server_claim" "ocp_user" {
  auth_server_id = okta_auth_server.oidc_auth_server.id
  name           = "ocp_user"
  value          = "user.firstName"
#  scopes         = ["any"]
  claim_type     = "RESOURCE"
}






# Add policy and rules to the authorization server

resource "okta_auth_server_policy" "auth_policy" {
  name             = "ocp_policy"
  auth_server_id   = okta_auth_server.oidc_auth_server.id
  description      = "Policy for allowed clients"
  priority         = 1
  client_whitelist = [okta_app_oauth.ocp_okta.id]
}

resource "okta_auth_server_policy_rule" "auth_policy_rule" {
  name           = "AuthCode + PKCE"
  auth_server_id = okta_auth_server.oidc_auth_server.id
  policy_id      = okta_auth_server_policy.auth_policy.id
  priority       = 1
  grant_type_whitelist = [
    "authorization_code"
  ]
  scope_whitelist = ["*"]
  group_whitelist = ["EVERYONE"]
}

