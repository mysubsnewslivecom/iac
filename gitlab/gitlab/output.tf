output "pat_tokens" {
  description = "Map of generated personal access tokens keyed by token name"
  value       = { for k, m in module.pat : k => m.token }
  sensitive   = true
}
