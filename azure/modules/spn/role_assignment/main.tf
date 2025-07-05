# modules/role_assignment/main.tf
resource "azurerm_role_assignment" "role_assignment" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = var.role_assignment
  principal_id         = var.service_principal_id
}
