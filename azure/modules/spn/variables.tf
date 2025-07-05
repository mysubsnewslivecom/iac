# modules/spn/variables.tf
variable "spn_name" {
  description = "Name of the SPN"
  type        = string
}

variable "owner_object_id" {
  description = "Owner object ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string

  validation {
    condition     = can(regex("^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$", var.subscription_id))
    error_message = "Subscription ID must be a valid GUID."
  }
}

variable "role_assignment" {
  description = "Role assignment name (e.g., Contributor, Reader)"
  type        = string
}
