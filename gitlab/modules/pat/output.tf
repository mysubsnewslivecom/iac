output "token" {
  description = "The generated personal access token"
  value       = gitlab_personal_access_token.personal_access_token.token
  sensitive   = true
}
