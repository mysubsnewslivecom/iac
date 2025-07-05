# application Module

Creates an Azure AD Application with a unique name using a random suffix.

## Inputs

| Name              | Description                         | Type   |
| ----------------- | ----------------------------------- | ------ |
| `spn_name`        | Base name of the application        | string |
| `owner_object_id` | Azure AD object ID of the app owner | string |

## Outputs

| Name        | Description                  |
| ----------- | ---------------------------- |
| `app_id`    | Object ID of the application |
| `client_id` | Application (client) ID      |

## Example

```hcl
module "application" {
  source          = "./modules/application"
  spn_name        = "my-spn"
  owner_object_id = var.owner_object_id
}
