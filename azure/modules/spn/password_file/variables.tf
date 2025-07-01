# modules/password_file/variables.tf
variable "password_resource" {
  description = "Password resource"
  type        = any
}

variable "sp_reader_name" {
  description = "Service Principal Reader Name"
  type        = string
}

variable "password_value" {
  description = "Service Principal Password"
  type        = string
}

variable "client_id" {
  description = "Service Principal Client ID"
  type        = string
}
