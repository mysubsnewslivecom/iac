# modules/application/variables.tf
variable "spn_name" {
  description = "Base name for the Azure AD Application (a random suffix will be appended)"
  type        = string
}

variable "owner_object_id" {
  description = "Azure AD Object ID of the application owner"
  type        = string
}
