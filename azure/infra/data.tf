# Get current subscription details
data "azurerm_subscription" "current" {}

# Get current Azure AD client config (for ownership)
data "azuread_client_config" "current" {}
