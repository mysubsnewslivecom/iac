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
}
variable "role_assignment" {
  description = "Role assignment"
  type        = string
}
