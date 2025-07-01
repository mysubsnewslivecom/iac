# modules/sp_password/main.tf
resource "azuread_application_password" "spn" {
  application_id = var.application_id
  display_name   = "sp-password"
}

output "password_value" {
  value = azuread_application_password.spn.value
}
