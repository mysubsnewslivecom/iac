# modules/role_assignment/variables.tf
variable "subscription_id" {
  description = "Azure Subscription ID used as the scope for the role assignment"
  type        = string

  validation {
    condition     = can(regex("^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$", var.subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "service_principal_id" {
  description = "The object ID of the Azure AD service principal to assign the role to"
  type        = string
}

variable "role_assignment" {
  description = "Name of the built-in role to assign (e.g., Reader, Contributor)"
  type        = string
}
