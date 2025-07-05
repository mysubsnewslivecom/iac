output "app_id" {
  description = "The object ID of the Azure AD application"
  value       = azuread_application.app.id
}

output "client_id" {
  description = "The client/application ID of the Azure AD application"
  value       = azuread_application.app.client_id
}
