# role_assignment Module

Assigns a role to an Azure AD service principal at the subscription level.

## Inputs

| Name                   | Description                                 | Type   |
| ---------------------- | ------------------------------------------- | ------ |
| `subscription_id`      | Azure subscription ID                       | string |
| `service_principal_id` | Object ID of the Azure AD service principal | string |
| `role_assignment`      | Name of the role to assign (e.g., Reader)   | string |

## Outputs

| Name                 | Description                       |
| -------------------- | --------------------------------- |
| `role_assignment_id` | ID of the created role assignment |

## Example

```hcl
module "role_assignment" {
  source               = "./modules/role_assignment"
  subscription_id      = var.subscription_id
  service_principal_id = module.service_principal.service_principal_id
  role_assignment      = "Reader"
}
