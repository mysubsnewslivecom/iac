# modules/password_file/variables.tf
variable "password_resource" {
  description = "Dependent resource for password creation"
  type        = any
}

variable "spn_name" {
  description = "Label or section name used in the output file"
  type        = string
}

variable "password_value" {
  description = "The actual secret value of the SPN"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Client ID of the service principal"
  type        = string
}
