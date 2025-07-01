# modules/sp_password/main.tf
resource "azuread_application_password" "spn" {
  application_id = var.application_id
  display_name   = "sp-password"
}

resource "vault_kv_secret_v2" "azuread_credentials" {
  mount = "kv"
  name  = "azuread/${var.application_id}"

  data_json = jsonencode({
    client_id     = var.application_id
    client_secret = azuread_application_password.spn.value
  })
}

output "client_id" {
  value     = var.application_id
  sensitive = true
}

output "client_secret" {
  value     = azuread_application_password.spn.value
  sensitive = true
}
