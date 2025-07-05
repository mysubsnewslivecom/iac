# main.tf
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "spn-reader" {
  source          = "../modules/spn"
  spn_name        = "spn-reader"
  owner_object_id = data.azuread_client_config.current.object_id
  subscription_id = data.azurerm_subscription.current.subscription_id
  role_assignment = var.role_assignment["reader"]
}

module "spn-contributor" {
  source          = "../modules/spn"
  spn_name        = "spn-contributor"
  owner_object_id = data.azuread_client_config.current.object_id
  subscription_id = data.azurerm_subscription.current.subscription_id
  role_assignment = var.role_assignment["contributor"]
}
