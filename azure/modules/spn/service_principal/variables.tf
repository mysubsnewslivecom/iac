# modules/service_principal/variables.tf
variable "client_id" {
  description = "Client ID of the Azure AD application"
  type        = string
}

variable "owner_object_id" {
  description = "Owner object ID"
  type        = string
}
