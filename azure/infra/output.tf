
# # Outputs for convenience
# output "client_id" {
#   description = "Service Principal Application (client) ID"
#   value       = azuread_application.app.client_id
# }

# output "client_secret" {
#   description = "Service Principal client secret"
#   value       = azuread_application_password.spn.value
#   sensitive   = true
# }

# output "tenant_id" {
#   description = "Azure Tenant ID"
#   value       = data.azuread_client_config.current.tenant_id
# }
