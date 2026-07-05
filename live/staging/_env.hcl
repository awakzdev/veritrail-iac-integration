locals {
  environment = "staging"
  name_prefix = "free-staging"

  # Regional network settings.
  vpc_cidr            = "10.20.0.0/16"
  public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]

  # Empty by default: no inbound access until you opt in.
  allowed_ingress_cidrs = []
  allowed_ingress_ports = []

  # Optional. Disabled because account aliases are global and only one can exist.
  create_account_alias = false
  account_alias        = "free-staging-account"

  environment_tags = {
    Environment = "staging"
  }
}
