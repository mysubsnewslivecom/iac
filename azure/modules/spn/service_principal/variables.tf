variable "client_id" {
  description = "The client ID (application ID) of the Azure AD application"
  type        = string
}

variable "owner_object_id" {
  description = "Azure AD Object ID of the owner for the service principal"
  type        = string
}
