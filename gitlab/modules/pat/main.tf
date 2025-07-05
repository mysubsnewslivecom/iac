resource "gitlab_personal_access_token" "personal_access_token" {
  user_id    = var.user_id
  name       = var.name
  expires_at = local.expires_at
  scopes     = var.scope
}
