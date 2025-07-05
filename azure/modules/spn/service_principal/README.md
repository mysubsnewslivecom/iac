# service_principal Module

Creates an Azure AD Service Principal for an existing application.

## Inputs

| Name              | Description                         | Type   |
| ----------------- | ----------------------------------- | ------ |
| `client_id`       | Application (client) ID             | string |
| `owner_object_id` | Azure AD object ID for the SP owner | string |

## Outputs

| Name                   | Description                         |
| ---------------------- | ----------------------------------- |
| `service_principal_id` | Object ID of the service principal  |
| `client_id`            | Client ID of the SP (same as input) |

## Example

```hcl
module "service_principal" {
  source          = "./modules/service_principal"
  client_id       = module.application.client_id
  owner_object_id = var.owner_object_id
}
