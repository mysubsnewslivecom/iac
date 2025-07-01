## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.k8sgpt](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.k8sgpt](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/cluster_role_binding) | resource |
| [kubernetes_deployment.k8sgpt](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/deployment) | resource |
| [kubernetes_manifest.service_monitor](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/manifest) | resource |
| [kubernetes_secret.ai_backend](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/secret) | resource |
| [kubernetes_service.k8sgpt](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/service) | resource |
| [kubernetes_service_account.k8sgpt](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend"></a> [backend](#input\_backend) | n/a | `string` | `"openai"` | no |
| <a name="input_enable_service_monitor"></a> [enable\_service\_monitor](#input\_enable\_service\_monitor) | n/a | `bool` | `false` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | n/a | `string` | `"Always"` | no |
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | n/a | `string` | `"ghcr.io/k8sgpt-ai/k8sgpt"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | n/a | `string` | `"latest"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | <pre>{<br/>  "app.kubernetes.io/instance": "k8sgpt",<br/>  "app.kubernetes.io/name": "k8sgpt"<br/>}</pre> | no |
| <a name="input_model"></a> [model](#input\_model) | n/a | `string` | `"gpt-3.5-turbo"` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"k8sgpt"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `"default"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | n/a | <pre>object({<br/>    limits = map(string)<br/>    requests = map(string)<br/>  })</pre> | <pre>{<br/>  "limits": {<br/>    "cpu": "1",<br/>    "memory": "512Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "0.2",<br/>    "memory": "156Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `string` | n/a | yes |
| <a name="input_security_context"></a> [security\_context](#input\_security\_context) | n/a | `map(any)` | `{}` | no |
| <a name="input_service_annotations"></a> [service\_annotations](#input\_service\_annotations) | n/a | `map(string)` | `{}` | no |
| <a name="input_service_monitor_additional_labels"></a> [service\_monitor\_additional\_labels](#input\_service\_monitor\_additional\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | n/a | `string` | `"ClusterIP"` | no |

## Outputs

No outputs.
