output "service_principal_id" {
  description = "The object ID of the created service principal"
  value       = module.service_principal.service_principal_id
}

output "client_id" {
  description = "The client ID of the service principal"
  value       = module.service_principal.client_id
}

output "client_secret" {
  description = "The client secret for the service principal"
  value       = module.sp_password.client_secret
  sensitive   = true
}
