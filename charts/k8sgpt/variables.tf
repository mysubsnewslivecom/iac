variable "name" {
  type    = string
  default = "k8sgpt"
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "labels" {
  type = map(string)
  default = {
    "app.kubernetes.io/name"     = "k8sgpt"
    "app.kubernetes.io/instance" = "k8sgpt"
  }
}

variable "image_repository" {
  type    = string
  default = "ghcr.io/k8sgpt-ai/k8sgpt"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "image_pull_policy" {
  type    = string
  default = "Always"
}

variable "model" {
  type    = string
  default = "gpt-3.5-turbo"
}

variable "backend" {
  type    = string
  default = "openai"
}

variable "resources" {
  type = object({
    limits   = map(string)
    requests = map(string)
  })
  default = {
    limits = {
      cpu    = "1"
      memory = "512Mi"
    }
    requests = {
      cpu    = "0.2"
      memory = "156Mi"
    }
  }
}

variable "security_context" {
  type    = map(any)
  default = {}
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "service_type" {
  type    = string
  default = "ClusterIP"
}

variable "service_annotations" {
  type    = map(string)
  default = {}
}

variable "enable_service_monitor" {
  type    = bool
  default = false
}

variable "service_monitor_additional_labels" {
  type    = map(string)
  default = {}
}
