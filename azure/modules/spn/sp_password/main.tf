# modules/sp_password/main.tf
resource "azuread_application_password" "spn" {
  application_id = var.application_id
  display_name   = "sp-password"
}

resource "vault_kv_secret_v2" "azuread_credentials" {
  mount = var.vault_mount_path
  name  = "azuread/${var.spn_name}"

  data_json = jsonencode({
    client_id     = var.client_id
    client_secret = azuread_application_password.spn.value
  })
}
