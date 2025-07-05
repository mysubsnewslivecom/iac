output "credentials_file" {
  description = "Path to the output credentials file"
  value       = abspath("${path.module}/root_token.txt")
}
