locals {
  environment = "dev"
  name_prefix = "free-dev"

  # Regional network settings.
  vpc_cidr            = "10.10.0.0/16"
  public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]

  # Empty by default: no inbound access until you opt in.
  allowed_ingress_cidrs = []
  allowed_ingress_ports = []

  # Optional. Disabled because account aliases are global and only one can exist.
  create_account_alias = false
  account_alias        = "free-dev-account"

  environment_tags = {
    Environment = "dev"
  }
}
