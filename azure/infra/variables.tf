variable "spn_name" {
  description = "spn reader name middle"
  type        = string
  default     = "reader"
}

variable "role_assignment" {
  description = "SPN role to be granted"
  type        = map(string)
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._\\-()]{1,90}$", var.resource_group_name))
    error_message = "The resource group name must be 1-90 characters long and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "location" {
  description = "location of the resource group"
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "tags"
  type        = map(string)
}
