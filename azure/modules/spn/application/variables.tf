# modules/application/variables.tf
variable "spn_name" {
  description = "Name of the SPN"
  type        = string
}

variable "owner_object_id" {
  description = "Owner object ID"
  type        = string
}
