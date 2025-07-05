output "service_principal_id" {
  description = "The object ID of the service principal"
  value       = azuread_service_principal.spn.object_id
}

output "client_id" {
  description = "The client ID of the service principal"
  value       = azuread_service_principal.spn.client_id
}
