variable "gitlab_token" {
  description = "GitLab token for authentication"
  type        = string
  sensitive   = true
}

variable "user_id" {
  description = "GitLab user ID for whom tokens are generated"
  type        = number
}

variable "tokens_config" {
  description = "Map of token names to their list of scopes"
  type        = map(list(string))
  default = {
    vscode   = ["api"]
    read_api = ["read_api"]
  }
}
