## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 3.4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.34.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_spn-contributor"></a> [spn-contributor](#module\_spn-contributor) | ../modules/spn | n/a |
| <a name="module_spn-reader"></a> [spn-reader](#module\_spn-reader) | ../modules/spn | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.34.0/docs/resources/resource_group) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/3.4.0/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.34.0/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | location of the resource group | `string` | `"centralindia"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_role_assignment"></a> [role\_assignment](#input\_role\_assignment) | SPN role to be granted | `map(string)` | n/a | yes |
| <a name="input_spn_name"></a> [spn\_name](#input\_spn\_name) | spn reader name middle | `string` | `"reader"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags | `map(string)` | n/a | yes |

## Outputs

No outputs.
