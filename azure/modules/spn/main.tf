# modules/spn/main.tf
module "application" {
  source          = "./application"
  spn_name        = var.spn_name
  owner_object_id = var.owner_object_id
}

module "service_principal" {
  source          = "./service_principal"
  client_id       = module.application.client_id
  owner_object_id = var.owner_object_id
}

module "sp_password" {
  source         = "./sp_password"
  application_id = module.application.app_id
  spn_name       = var.spn_name
  client_id      = module.service_principal.client_id
}

module "role_assignment" {
  source               = "./role_assignment"
  subscription_id      = var.subscription_id
  service_principal_id = module.service_principal.service_principal_id
  role_assignment      = var.role_assignment
}

module "password_file" {
  source            = "./password_file"
  password_resource = module.sp_password.client_secret
  spn_name          = var.spn_name
  password_value    = module.sp_password.client_secret
  client_id         = module.service_principal.client_id
}
