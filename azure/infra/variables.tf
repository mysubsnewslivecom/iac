variable "role_assignment" {
  description = "SPN role to be granted"
  type        = map(string)
  default = {
    reader      = "Reader"
    contributor = "Contributor"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9.\\-()]{1,90}$", var.resource_group_name))
    error_message = "The resource group name must be 1-90 characters long and contain only letters, numbers, hyphens, dots, or parentheses."
  }
}

variable "location" {
  description = "Location of the resource group"
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
