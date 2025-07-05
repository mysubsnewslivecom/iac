# password_file Module

Writes SPN credentials (client ID and secret) to a local file using `null_resource` and `local-exec`.

⚠️ This module is intended for dev/test use only. Avoid using it in production unless secure storage (e.g., Azure Key Vault) is unavailable.

## Inputs

| Name                | Description                              | Type   |
| ------------------- | ---------------------------------------- | ------ |
| `password_resource` | A resource to depend on before execution | any    |
| `sp_reader_name`    | Section/label in output file             | string |
| `password_value`    | SPN secret                               | string |
| `client_id`         | SPN client ID                            | string |

## Outputs

| Name               | Description                |
| ------------------ | -------------------------- |
| `credentials_file` | Path to the generated file |

## Example

```hcl
module "password_file" {
  source            = "./modules/password_file"
  password_resource = module.sp_password.client_secret
  sp_reader_name    = var.spn_name
  password_value    = module.sp_password.client_secret
  client_id         = module.service_principal.client_id
}
