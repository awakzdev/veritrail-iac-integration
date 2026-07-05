locals {
  environment = "global"
  name_prefix = "free"

  # Optional. Disabled because account aliases are global and user-specific.
  create_account_alias = false
  account_alias        = "free-baseline-account"

  environment_tags = {
    Environment = "global"
  }
}
