# modules/role_assignment/variables.tf
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "service_principal_id" {
  description = "Service Principal ID"
  type        = string
}
variable "role_assignment" {
  description = "Service Principal role"
  type        = string
}
