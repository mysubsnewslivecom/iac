output "tenant_id" {
  description = "Azure Tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "spn_reader_client_id" {
  description = "Service Principal Reader Client ID"
  value       = module.spn-reader.client_id
}

output "spn_reader_client_secret" {
  description = "Service Principal Reader Client Secret"
  value       = module.spn-reader.client_secret
  sensitive   = true
}

output "spn_contributor_client_id" {
  description = "Service Principal Contributor Client ID"
  value       = module.spn-contributor.client_id
}

output "spn_contributor_client_secret" {
  description = "Service Principal Contributor Client Secret"
  value       = module.spn-contributor.client_secret
  sensitive   = true
}
