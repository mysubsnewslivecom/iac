variable "user_id" {
  description = "GitLab user ID"
  type        = number
}

variable "name" {
  description = "Personal access token name"
  type        = string
}

variable "scope" {
  description = "Scopes of the personal access token"
  type        = list(string)
  default     = ["api"]

  validation {
    condition = alltrue([
      for s in var.scope : contains(
        [
          "api", "read_user", "read_api", "read_repository", "write_repository",
          "read_registry", "write_registry", "read_virtual_registry", "write_virtual_registry",
          "sudo", "admin_mode", "create_runner", "manage_runner", "ai_features",
          "k8s_proxy", "self_rotate", "read_service_ping"
      ], s)
    ])
    error_message = "Invalid scope: all scopes must be one of the allowed values."
  }
}
