# modules/sp_password/variables.tf
variable "application_id" {
  description = "Application ID of the Azure AD application"
  type        = string
}

variable "vault_mount_path" {
  description = "Vault mount path where secrets will be stored"
  type        = string
  default     = "secret"
}

variable "spn_name" {
  description = "Name of the SPN"
  type        = string
}

variable "client_id" {
  description = "The client ID (application ID) of the Azure AD application"
  type        = string
}
