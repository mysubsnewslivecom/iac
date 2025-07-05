output "client_id" {
  description = "The application (client) ID"
  value       = var.application_id
  sensitive   = true
}

output "client_secret" {
  description = "The generated client secret"
  value       = azuread_application_password.spn.value
  sensitive   = true
}
