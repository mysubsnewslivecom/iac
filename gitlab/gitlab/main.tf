module "pat" {
  source   = "../modules/pat"
  for_each = var.tokens_config

  user_id = var.user_id
  name    = each.key
  scope   = each.value

  # providers = {
  #   gitlab = gitlabhq
  # }
}
