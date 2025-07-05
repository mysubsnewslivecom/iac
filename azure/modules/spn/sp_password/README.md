# sp_password Module

Generates a client secret for an Azure AD Application and stores it in Vault.

## Inputs

| Name               | Description                         | Type   |
| ------------------ | ----------------------------------- | ------ |
| `application_id`   | The ID of the Azure AD application  | string |
| `vault_mount_path` | Vault KV mount path (default: `kv`) | string |

## Outputs

| Name            | Description             |
| --------------- | ----------------------- |
| `client_id`     | Application (client) ID |
| `client_secret` | Generated client secret |

## Example

```hcl
module "sp_password" {
  source         = "./modules/sp_password"
  application_id = module.application.app_id
}
