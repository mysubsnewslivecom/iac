resource "kubernetes_service_account" "k8sgpt" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
  }
}

resource "kubernetes_cluster_role" "k8sgpt" {
  metadata {
    name   = var.name
    labels = var.labels
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "k8sgpt" {
  metadata {
    name   = var.name
    labels = var.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = var.name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_secret" "ai_backend" {
  metadata {
    name      = "ai-backend-secret"
    namespace = var.namespace
  }

  data = {
    "secret-key" = base64encode(var.secret_key)
  }

  type = "Opaque"
}

resource "kubernetes_service" "k8sgpt" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.service_annotations
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = var.name
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    port {
      name        = "metrics"
      port        = 8081
      target_port = 8081
    }

    type = var.service_type
  }
}

resource "kubernetes_deployment" "k8sgpt" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name"     = var.name
        "app.kubernetes.io/instance" = var.name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"     = var.name
          "app.kubernetes.io/instance" = var.name
        }
      }

      spec {
        service_account_name = var.name

        container {
          name              = "k8sgpt-container"
          image             = "${var.image_repository}:${var.image_tag}"
          image_pull_policy = var.image_pull_policy
          args              = ["serve"]

          port {
            container_port = 8080
          }

          env {
            name  = "K8SGPT_MODEL"
            value = var.model
          }

          env {
            name  = "K8SGPT_BACKEND"
            value = var.backend
          }

          env {
            name  = "XDG_CONFIG_HOME"
            value = "/k8sgpt-config/"
          }

          env {
            name  = "XDG_CACHE_HOME"
            value = "/k8sgpt-config/"
          }

          env {
            name = "K8SGPT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "ai-backend-secret"
                key  = "secret-key"
              }
            }
          }

          resources {
            limits   = var.resources["limits"]
            requests = var.resources["requests"]
          }

          volume_mount {
            name       = "config"
            mount_path = "/k8sgpt-config"
          }
        }

        volume {
          name = "config"
          empty_dir {}
        }

        dynamic "security_context" {
          for_each = var.security_context != {} ? [1] : []
          content {
            run_as_user  = lookup(var.security_context, "runAsUser", null)
            run_as_group = lookup(var.security_context, "runAsGroup", null)
          }
        }
      }
    }
  }
}

# resource "kubernetes_manifest" "service_monitor" {
#   count = var.enable_service_monitor ? 1 : 0

#   manifest = {
#     apiVersion = "monitoring.coreos.com/v1"
#     kind       = "ServiceMonitor"
#     metadata = {
#       name      = var.name
#       namespace = var.namespace
#       labels    = merge(var.labels, var.service_monitor_additional_labels)
#     }
#     spec = {
#       selector = {
#         matchLabels = {
#           "app.kubernetes.io/name"     = var.name
#           "app.kubernetes.io/instance" = var.name
#         }
#       }
#       endpoints = [{
#         honorLabels = true
#         path        = "/metrics"
#         port        = "metrics"
#       }]
#     }
#   }
# }
