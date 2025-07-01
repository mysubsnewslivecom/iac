# modules/application/main.tf
resource "random_id" "suffix" {
  byte_length = 4
}

resource "azuread_application" "app" {
  # display_name = "${var.spn_name}-${random_id.suffix.hex}"
  display_name = var.spn_name
  owners       = [var.owner_object_id]
}

output "app_id" {
  value = azuread_application.app.id
}

output "client_id" {
  value = azuread_application.app.client_id
}
