# modules/service_principal/main.tf
resource "azuread_service_principal" "spn" {
  client_id                    = var.client_id
  app_role_assignment_required = false
  owners                       = [var.owner_object_id]
}

output "service_principal_id" {
  value = azuread_service_principal.spn.object_id
}

output "client_id" {
  value = azuread_service_principal.spn.client_id
}
